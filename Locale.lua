local L, _, T = {}, ...

T.L = newproxy(true)
getmetatable(T.L).__call = function(self, k)
	return L[k] or k -- k:gsub("%a%a%a+", string.reverse)
end