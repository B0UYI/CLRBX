--!strict
-- Affichage des grands nombres : 950 → « 950 », 12 345 → « 12,3K », 5 600 000 → « 5,6M ».

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

local Format = {}

function Format.Number(value: number): string
	if value ~= value then
		return "0" -- NaN
	end
	local sign = if value < 0 then "-" else ""
	local n = math.abs(value)
	local tier = 1
	while n >= 1000 and tier < #SUFFIXES do
		n /= 1000
		tier += 1
	end
	if tier == 1 then
		return sign .. tostring(math.floor(n))
	end
	local text
	if n >= 100 then
		text = tostring(math.floor(n))
	elseif n >= 10 then
		text = string.format("%.1f", math.floor(n * 10) / 10)
	else
		text = string.format("%.2f", math.floor(n * 100) / 100)
	end
	text = (string.gsub(text, "%.", ","))
	return sign .. text .. SUFFIXES[tier]
end

return Format
