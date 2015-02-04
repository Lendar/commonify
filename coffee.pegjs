start = type:amdkeyword rest {return type;}
amdkeyword = 'require' / 'define'
rest = .*
