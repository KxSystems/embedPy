sys:.p.import`sys
sysconfig:.p.import`sysconfig

qPrefix:sys[`:prefix]`
qBasePrefix:sys[`:base_prefix]`
// Have to remove q path to coincide with python
qPath:":" sv ((sys[`:path]`) except enlist getenv`QHOME)
qVersion:3#sys[`:version_info]`
qLibdir:sysconfig[`:get_config_var]["LIBDIR"]`

pyPrefix:raze system"python -c \"import sys; print(sys.prefix)\""
pyBasePrefix:raze system"python -c \"import sys; print(sys.base_prefix)\""
pyPath:raze system"python -c \"import sys; print(':'.join(sys.path))\""
pyVersion:"J"$3#system"python -c \"import sys; [print(getattr(sys.version_info,val)) for val in ('major','minor','micro','releaselevel','serial')]\""
pyLibdir:raze system"python -c \"import sysconfig; print(sysconfig.get_config_var('LIBDIR'))\""

qPrefix~pyPrefix
qBasePrefix~pyBasePrefix
qPath~pyPath
qVersion~pyVersion
qLibdir~pyLibdir
