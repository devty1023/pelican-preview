import jinja2
import os

templateLoader = jinja2.FileSystemLoader(searchpath='./')
templateEnv = jinja2.Environment(loader=templateLoader)
template = templateEnv.get_template("pre_home.html")

themes = [ name for name in os.listdir("./output") if os.path.isdir(os.path.join("./output", name)) ]
themes=sorted(themes, key=lambda s: s.lower())
themes.remove(".git")
themes.remove("static-css")

print template.render(themes=themes)

