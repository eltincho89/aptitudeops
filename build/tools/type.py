import sys,subprocess
SH={'_':'minus','|':'backslash','>':'dot',':':'semicolon','"':'apostrophe','$':'4','#':'3','*':'8','&':'7','(':'9',')':'0','~':'grave_accent','@':'2','%':'5','<':'comma','?':'slash','+':'equal','{':'bracket_left','}':'bracket_right','!':'1'}
PL={' ':'spc','/':'slash','.':'dot','-':'minus','=':'equal','\\':'backslash',"'":'apostrophe',';':'semicolon',',':'comma','[':'bracket_left',']':'bracket_right','`':'grave_accent','\n':'ret'}
keys=[]
for ch in sys.argv[2]:
    if ch in PL: keys.append(PL[ch])
    elif ch in SH: keys.append('shift-'+SH[ch])
    elif ch.isupper(): keys.append('shift-'+ch.lower())
    else: keys.append(ch)
keys.append('ret') if len(sys.argv)>3 else None
subprocess.run(['python3',sys.argv[1]+'/keys.py',sys.argv[1]]+keys)
