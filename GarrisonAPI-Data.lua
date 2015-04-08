local _, T = ...
if T.Mark ~= 23 then return end

T.Affinities = {} do
	local ht, hp = [[ ƒKÝä12I^œœ|ÞÛÐ‰Œbú,ÑSÞG‘Ãœ§mÓ3€ö¿YªÆÕ²?V=;‰ÀÔê&ë£XÅÒðD	ê…™è¥”íJÊUÑwU“Ü|M‹ãeör>Î•—¡&[äÇ¡_œþíèFßâtÖ‘yÊœÍ{Áê«kh›ç[Ñß$þb£sb³«ó`°~YMHÙÝ™zN©Y¸‰&YHŽ~Ž™d¯DÉZ>ÕŒfˆö>d©Ÿ¼‹Për6{ÌÖ*¥¾äE6ƒ„!d•µ¶r›×Ñ‰"×$ë>”Aî"Ü´¥ð“>xZB"N!Óò!ïzú3ƒž•¾+!ÜøÄ‡I'J	"&ÔtoÒ…œíBÖ91ZPD!ò‹ß)R¢PôI“[è'ë›Èç:N='óÁi;ÃÑÔ¡#¡gyæÉ6M£ŽÕ°î9Ø”¾){3¦“aÚr9+i„ÊˆDŽò&G”ãHŽ#—ÎkÉ~4!È´¡ˆ#æ˜¥[ÖøÁ} †Ñ,aGElŠèy­p|ÞvÎ'dHHºGD$ÍJ%G¾la#¥+J·Î$bÉEÑ’B>“s#œôrÐz1u6‚È¸¢(rv¡ÏƒZtÉhbÏÊQt·Ê+„ØÃºƒœèü‹bY%¡’ØF äŒVù²'#H¦‘‚ÓDDñ›%)R$KÞÄ9g{„®i]Æ1‘ÿþ×0’]], [[(((h((inq(pjgkrso(lm]]
	local p, G, V, Vp, by, hk, ak = {}, 101, 541, 203, ht.byte, UnitFactionGroup('player') == 'Horde' and 15030 or 3110, 55683
	for i=1,#hp do p[i] = by(hp, i) - 40 end
	setmetatable(T.Affinities, {__index=function(t, k)
		local k, c, a, v, r, b, d, e = k or false, k, type(k)
		if a == "string" then
			a, c = "number", tonumber(k:match("^0x0*(%x*)$") or "z", 16) or false
		end
		if a == "number" and c then
			c = c * hk
			a = 2*(((c * ak) % 2147483629) % G)
			a, b = by(ht, a+1, a+2)
			v = ((c * (a*256+b) + ak) % 2147483629) % V
			v, r = Vp + (v - v % 8)*5/8, v % 8
			a, b, c, d, e = by(ht, v, v + 4)
			v = a * 4294967296 + b * 16777216 + c * 65536 + d * 256 + e
			v = ((v - v % 32^r) / 32^r % 32)
		end
		t[k] = p[v] or 0
		return t[k]
	end})
end

T.MissionExpire = {} do
	local expire = T.MissionExpire
	for n, r in ("000210611621id2e56516c16o17i0:0ga6b:0o2103rz4rz5r86136716e26q37ji9549eja23ai1al3aqg:102zd3h86vm82mak0ap0:1y9a39y3:20050100190:9b8pfb7a"):gmatch("(%w%w)(%w+)") do
		local n = tonumber(n, 36)
		for s, l in r:gmatch("(%w%w)(%w)") do
			local s = tonumber(s, 36)
			for i=s, s+tonumber(l, 36) do
				expire[i] = n
			end
		end
	end
end

T.EnvironmentCounters = {[11]=4, [12]=38, [13]=42, [14]=43, [15]=37, [16]=36, [17]=40, [18]=41, [19]=42, [20]=39, [21]=7, [22]=9, [23]=8, [24]=45, [25]=46, [26]=44, [27]=47, [28]=48, [29]=49,}

T.SpecCounters = { nil, {1,2,7,8,10}, {1,4,7,8,10}, {1,2,7,8,10}, {6,7,9,10}, nil, {1,2,6,10}, {1,2,6,9}, {3,4,7,9}, {1,6,7,9,10}, nil, {6,7,8,9,10}, {2,6,7,9,10}, {6,8,9,10}, {6,7,8,9,10}, {2,7,8,9,10}, {1,2,3,6,9}, {3,4,6,8}, {1,6,8,9,10}, {3,4,8,9}, {1,2,4,8,9}, {2,7,8,9,10}, {3,4,6,9}, {3,4,6,7}, {4,6,7,9,10}, {2,6,8,9,10}, {6,7,8,9,10}, {2,6,7,8,9}, {3,7,8,9,10}, {3,6,7,9,10}, {3,4,7,8}, {4,7,8,9,10}, {2,7,8,10,10}, {3,8,9,10,10}, {1,6,7,8,10}, nil, {2,6,7,8,10}, {1,2,6,7,8} }

T.EquivTrait = {[244]=4, }

T.XPMissions = {[5]=1, [173]=1, [215]=1, [336]=1, [364]=1,}