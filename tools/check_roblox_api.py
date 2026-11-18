#!/usr/bin/env python3
"""Vérificateur léger d'usage de l'API Roblox dans src/ (sans Studio).

Lit un fichier de définitions Luau (globalTypes.None.d.luau du projet luau-lsp)
et signale dans notre code :
  - Enum.X.Y inexistants,
  - Instance.new("Classe") / GetService("Service") inconnus,
  - propriétés ou méthodes inexistantes sur des variables dont la classe est connue
    (Instance.new, annotations `nom: Classe`, casts `:: Classe`, FindFirstChildOfClass),
  - champs inexistants des types de données (Vector3.new, CFrame.Angles, ...).

Usage : python3 -I tools/check_roblox_api.py <globalTypes.None.d.luau> [dossier=src]
C'est une heuristique (pas un vrai typage) : elle vise les erreurs qui plantent à l'exécution.
"""
import os
import re
import sys

defs_path = sys.argv[1]
root = sys.argv[2] if len(sys.argv) > 2 else "src"
skip_dirs = {os.path.join(root, "server", "Packages")}

classes = {}  # name -> (super, set(members))
globals_tables = {}  # datatype global -> set(fields)
enum_internal = {}  # EnumName -> internal type
services = set()

with open(defs_path, encoding="utf-8") as f:
    lines = f.read().split("\n")

i = 0
while i < len(lines):
    line = lines[i]
    m = re.match(r"^declare (?:extern type|class) (\w+)(?: extends (\w+))?(?: with)?\s*$", line)
    if m:
        name, sup = m.group(1), m.group(2)
        members = set()
        i += 1
        while i < len(lines) and lines[i].strip() != "end":
            mm = re.match(r"^\s+(?:function\s+)?(\w+)\s*[:(]", lines[i])
            if mm:
                members.add(mm.group(1))
            sm = re.search(r'GetService\(self, service: "(\w+)"\)', lines[i])
            if sm:
                services.add(sm.group(1))
            i += 1
        classes[name] = (sup, members)
        i += 1
        continue
    m = re.match(r"^declare (\w+): \{\s*$", line)
    if m:
        name = m.group(1)
        fields = set()
        i += 1
        while i < len(lines) and not lines[i].startswith("}"):
            fm = re.match(r"^\s+(\w+)\s*:", lines[i])
            if fm:
                fields.add(fm.group(1))
            i += 1
        globals_tables[name] = fields
        i += 1
        continue
    m = re.match(r"^type ENUM_LIST = \{", line)
    if m:
        i += 1
        while i < len(lines) and not lines[i].startswith("}"):
            em = re.match(r"^\s+(\w+): (\w+),?", lines[i])
            if em:
                enum_internal[em.group(1)] = em.group(2)
            i += 1
        i += 1
        continue
    i += 1


def members_of(cls):
    seen = set()
    out = set()
    while cls and cls in classes and cls not in seen:
        seen.add(cls)
        sup, mem = classes[cls]
        out |= mem
        cls = sup
    return out


# Classes « conteneurs » : un accès `.Nom` peut viser un enfant -> on ne signale que les écritures.
CONTAINER_CLASSES = {"Folder", "Model", "Configuration", "ScreenGui", "Frame", "Workspace", "DataModel",
                     "ReplicatedStorage", "ServerScriptService", "PlayerGui", "Backpack", "Player", "Instance"}
KNOWN_VARS = {"workspace": "Workspace", "game": "DataModel"}

errors = []
warnings = []
checked = [0]


def report(kind, path, lineno, msg):
    (errors if kind == "E" else warnings).append(f"{path}:{lineno}: {msg}")


for dirpath, _, files in os.walk(root):
    if any(dirpath.startswith(s) for s in skip_dirs):
        continue
    for fname in files:
        if not fname.endswith(".luau"):
            continue
        path = os.path.join(dirpath, fname)
        with open(path, encoding="utf-8") as f:
            src_lines = f.read().split("\n")
        var_class = dict(KNOWN_VARS)
        for n, line in enumerate(src_lines, 1):
            code = re.sub(r"--.*$", "", line)
            code_nostr = re.sub(r'"[^"]*"', '""', code)
            # Enums
            for em in re.finditer(r"\bEnum\.(\w+)\.(\w+)", code):
                enum, item = em.groups()
                internal = enum_internal.get(enum)
                if not internal:
                    report("E", path, n, f"Enum.{enum} n'existe pas")
                elif item not in members_of(internal):
                    report("E", path, n, f"Enum.{enum}.{item} n'existe pas")
            # Instance.new / GetService
            for cm in re.finditer(r'Instance\.new\("(\w+)"\)', code):
                if cm.group(1) not in classes:
                    report("E", path, n, f'Instance.new("{cm.group(1)}") : classe inconnue')
            for sm in re.finditer(r'GetService\("(\w+)"\)', code):
                if sm.group(1) not in services and sm.group(1) not in classes:
                    report("E", path, n, f'GetService("{sm.group(1)}") : service inconnu')
            # Champs des types de données (Vector3.new, CFrame.Angles, ...)
            for gm in re.finditer(r"\b([A-Z]\w+)\.(\w+)\b", code_nostr):
                g, field = gm.groups()
                if g in globals_tables and g != "Enum" and field not in globals_tables[g]:
                    report("E", path, n, f"{g}.{field} n'existe pas")
            # Typage des variables
            for vm in re.finditer(r'\blocal (\w+)\s*=\s*Instance\.new\("(\w+)"\)', code):
                var_class[vm.group(1)] = vm.group(2)
            for vm in re.finditer(r"\b(\w+)\s*:\s*([A-Z]\w+)\??\b", code_nostr):
                if vm.group(2) in classes and vm.group(1) not in ("Enum",):
                    var_class[vm.group(1)] = vm.group(2)
            for vm in re.finditer(r'\blocal (\w+)\s*=\s*[\w.]+:FindFirstChildOfClass\("(\w+)"\)', code):
                var_class[vm.group(1)] = vm.group(2)
            for vm in re.finditer(r"\blocal (\w+)\s*=.*::\s*([A-Z]\w+)\s*$", code_nostr):
                if vm.group(2) in classes:
                    var_class[vm.group(1)] = vm.group(2)
            # Raffinement `if x:IsA("Classe")` : x est de cette classe dans la suite.
            for rm in re.finditer(r'(\w+):IsA\("(\w+)"\)', code):
                if rm.group(2) in classes:
                    var_class[rm.group(1)] = rm.group(2)
            # Usages var.Prop / var:Method(
            for um in re.finditer(r"(?<![.:\w])(\w+)([.:])(\w+)", code_nostr):
                var, sep, member = um.groups()
                cls = var_class.get(var)
                if not cls or cls not in classes:
                    continue
                checked[0] += 1
                if member in members_of(cls):
                    continue
                after = code_nostr[um.end():um.end() + 3]
                is_write = sep == "." and re.match(r"\s*=[^=]", code_nostr[um.end():]) is not None
                if sep == ":":
                    report("E", path, n, f"{var}:{member}() n'existe pas sur {cls}")
                elif is_write:
                    report("E", path, n, f"{var}.{member} n'est pas une propriété de {cls}")
                elif cls not in CONTAINER_CLASSES:
                    report("W", path, n, f"{var}.{member} inconnu sur {cls} (enfant ?)")

print(f"Définitions : {len(classes)} types, {len(enum_internal)} enums, {len(services)} services")
for e in errors:
    print("ERREUR  ", e)
for w in warnings:
    print("ATTENTION", w)
print(f"{checked[0]} usages vérifiés — {len(errors)} erreur(s), {len(warnings)} avertissement(s)")
sys.exit(1 if errors else 0)
