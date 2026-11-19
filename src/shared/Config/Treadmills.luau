--!strict
-- Tapis de course du lobby : rester dessus fait des pas automatiquement (sans bouger).
-- Débloqués par le TOTAL de victoires gagnées (dépenser ses victoires ne fait pas perdre l'accès).

export type Treadmill = {
	Id: string,
	Name: string,
	StepsPerSecond: number,
	RequiredWins: number,
	Color: Color3,
}

local List: { Treadmill } = {
	{ Id = "bois", Name = "Tapis de bois", StepsPerSecond = 2, RequiredWins = 0, Color = Color3.fromRGB(150, 105, 70) },
	{ Id = "fer", Name = "Tapis de fer", StepsPerSecond = 4, RequiredWins = 20, Color = Color3.fromRGB(160, 165, 175) },
	{ Id = "or", Name = "Tapis d'or", StepsPerSecond = 6, RequiredWins = 150, Color = Color3.fromRGB(255, 200, 60) },
	{
		Id = "diamant",
		Name = "Tapis de diamant",
		StepsPerSecond = 8,
		RequiredWins = 1000,
		Color = Color3.fromRGB(110, 230, 255),
	},
	{
		Id = "cosmique",
		Name = "Tapis cosmique",
		StepsPerSecond = 10,
		RequiredWins = 6000,
		Color = Color3.fromRGB(190, 90, 255),
	},
}

local byId: { [string]: Treadmill } = {}
for _, treadmill in List do
	assert(byId[treadmill.Id] == nil, `Tapis en double : {treadmill.Id}`)
	byId[treadmill.Id] = treadmill
end

return {
	List = List,
	ById = byId,
}
