.t.requiremod`bs4
bs:.p.import[`bs4]`:BeautifulSoup
bsobj:bs[{"c"$.p.import[`urllib.request][`:urlopen][x][`:read][]`}"https://code.kx.com/q/ref/iterators/";"html.parser"]
m_find_all:bsobj[`:find_all;*]
all`prefix`previous_element`parser_class`contents`previous_sibling`namespace`next_sibling`attrs`next_element`hidden`can_be_empty_element`name`parent in cols{.p.wrap[x][`$":__dict__";`]}each m_find_all["h2"]`
/m_find_all[(),"a";`class_  pykw "md-nav__link"]~m_find_all[(),"a";pykwargs enlist[`class_]!enlist"md-nav__link"]
