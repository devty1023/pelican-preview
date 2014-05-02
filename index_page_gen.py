import jinja2
import os

templateLoader = jinja2.FileSystemLoader(searchpath='./')
templateEnv = jinja2.Environment(loader=templateLoader)
template = templateEnv.get_template("pre_home.html")

themes = [ name for name in os.listdir("./output") if os.path.isdir(os.path.join("./output", name)) ]
themes=sorted(themes, key=lambda s: s.lower())
try:
    themes.remove(".git")
except Exception, e:
    #print ".git is not here. hew"
    pass
try:
    themes.remove("static-css")
except Exception, e:
    #print "static-css is not here. hew"
    pass
try:
    themes.remove("README.rst")
except Exception, e:
    #print "README.rst is not here. hew"
    pass


print template.render(themes=themes)

