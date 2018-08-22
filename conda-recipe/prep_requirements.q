/ exclude packages from tests/requirements.txt based on python major minor version
\l p.q
pexclude:select py37:enlist"tensorflow*" from (0#`)!()
pver:`$"py",raze string .p.import[`sys;`:version_info][;`]each`:major`:minor
`:tests/requirements_filtered.txt 0:u where not any(u:read0`:tests/requirements.txt)like/:pexclude pver
\\
