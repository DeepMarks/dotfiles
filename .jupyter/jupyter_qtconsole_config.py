# Configuration file for jupyter-qtconsole.

c.JupyterQtConsoleApp.confirm_exit = False
c.JupyterQtConsoleApp.hide_menubar = True

c.ConsoleWidget.font_family = 'Monospace'
c.ConsoleWidget.font_size = 11
c.ConsoleWidget.gui_completion = 'ncurses'
c.ConsoleWidget.include_other_output = True
c.ConsoleWidget.kind = 'rich'
c.ConsoleWidget.other_output_prefix = '[wsl] '
c.ConsoleWidget.paging = 'vsplit'
c.ConsoleWidget.scrollbar_visibility = False

color_theme = 'onedark'  # specify color theme
import pkg_resources
c.JupyterQtConsoleApp.stylesheet = pkg_resources.resource_filename(
            "jupyter_qtconsole_colorschemes", "{}.css".format(color_theme))
c.JupyterWidget.syntax_style = color_theme
