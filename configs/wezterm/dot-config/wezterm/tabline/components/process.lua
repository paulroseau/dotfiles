local wezterm = require('wezterm')
local component = require('tabline.component')
local palette = require('tabline.palette')

local default_icon = wezterm.nerdfonts.md_application

local process_to_component = {
  ['air'] = component.new('air', wezterm.nerdfonts.md_language_go, palette.cyan),
  ['apt'] = component.new('apt', wezterm.nerdfonts.dev_debian, palette.red),
  ['bacon'] = component.new('bacon', wezterm.nerdfonts.dev_rust, palette.red),
  ['bash'] = component.new('bash', wezterm.nerdfonts.cod_terminal_bash, palette.surface),
  ['bat'] = component.new('bat', wezterm.nerdfonts.md_bat, palette.blue),
  ['btm'] = component.new('btm', wezterm.nerdfonts.md_chart_donut_variant, palette.red),
  ['btop'] = component.new('btop', wezterm.nerdfonts.md_chart_areaspline, palette.red),
  ['btop4win++'] = component.new('btop4win++', wezterm.nerdfonts.md_chart_areaspline, palette.red),
  ['bun'] = component.new('bun', wezterm.nerdfonts.md_hamburger, palette.surface),
  ['cargo'] = component.new('cargo', wezterm.nerdfonts.dev_rust, palette.red),
  ['chezmoi'] = component.new('chezmoi', wezterm.nerdfonts.md_home_plus_outline, palette.cyan),
  ['cmd.exe'] = component.new('cmd.exe', wezterm.nerdfonts.md_console_line, palette.surface),
  ['curl'] = component.new('curl', wezterm.nerdfonts.md_flattr),
  ['debug'] = component.new('debug', wezterm.nerdfonts.cod_debug, palette.blue),
  ['docker'] = component.new('docker', wezterm.nerdfonts.md_docker, palette.blue),
  ['docker-compose'] = component.new('docker-compose', wezterm.nerdfonts.md_docker, palette.blue),
  ['dpkg'] = component.new('dpkg', wezterm.nerdfonts.dev_debian, palette.red),
  ['fish'] = component.new('fish', wezterm.nerdfonts.md_fish, palette.surface),
  ['gh'] = component.new('gh', wezterm.nerdfonts.dev_github_badge, palette.yellow),
  ['git'] = component.new('git', wezterm.nerdfonts.dev_git, palette.yellow),
  ['go'] = component.new('go', wezterm.nerdfonts.md_language_go, palette.cyan),
  ['htop'] = component.new('htop', wezterm.nerdfonts.md_chart_areaspline, palette.red),
  ['kubectl'] = component.new('kubectl', wezterm.nerdfonts.md_docker, palette.blue),
  ['kuberlr'] = component.new('kuberlr', wezterm.nerdfonts.md_docker, palette.blue),
  ['lazydocker'] = component.new('lazydocker', wezterm.nerdfonts.md_docker, palette.blue),
  ['lazygit'] = component.new('lazygit', wezterm.nerdfonts.cod_github, palette.yellow),
  ['lua'] = component.new('lua', wezterm.nerdfonts.seti_lua, palette.blue),
  ['make'] = component.new('make', wezterm.nerdfonts.seti_makefile),
  ['nix'] = component.new('nix', wezterm.nerdfonts.linux_nixos, palette.blue),
  ['node'] = component.new('node', wezterm.nerdfonts.md_nodejs, palette.red),
  ['npm'] = component.new('npm', wezterm.nerdfonts.md_npm, palette.red),
  ['nvim'] = component.new('nvim', wezterm.nerdfonts.custom_neovim, palette.green),
  ['pacman'] = component.new('pacman', wezterm.nerdfonts.md_pac_man, palette.yellow),
  ['paru'] = component.new('paru', wezterm.nerdfonts.md_pac_man, palette.yellow),
  ['pnpm'] = component.new('pnpm', wezterm.nerdfonts.md_npm, palette.yellow),
  ['postgresql'] = component.new('postgresql', wezterm.nerdfonts.dev_postgresql, palette.blue),
  ['powershell.exe'] = component.new('powershell.exe', wezterm.nerdfonts.md_console, palette.surface),
  ['psql'] = component.new('psql', wezterm.nerdfonts.dev_postgresql, palette.blue),
  ['pwsh.exe'] = component.new('pwsh.exe', wezterm.nerdfonts.md_console, palette.surface),
  ['python'] = component.new('python', wezterm.nerdfonts.dev_python, palette.surface),
  ['rpm'] = component.new('rpm', wezterm.nerdfonts.dev_redhat, palette.red),
  ['redis'] = component.new('redis', wezterm.nerdfonts.dev_redis, palette.blue),
  ['ruby'] = component.new('ruby', wezterm.nerdfonts.cod_ruby, palette.red),
  ['rust'] = component.new('rust', wezterm.nerdfonts.dev_rust, palette.red),
  ['serial'] = component.new('serial', wezterm.nerdfonts.md_serial_port),
  ['ssh'] = component.new('ssh', wezterm.nerdfonts.md_ssh),
  ['sudo'] = component.new('sudo', wezterm.nerdfonts.fa_hashtag),
  ['tls'] = component.new('tls', wezterm.nerdfonts.md_power_socket),
  ['topgrade'] = component.new('topgrade', wezterm.nerdfonts.md_rocket_launch, palette.blue),
  ['unix'] = component.new('unix', wezterm.nerdfonts.md_bash),
  ['valkey'] = component.new('valkey', wezterm.nerdfonts.dev_redis, palette.cyan),
  ['vim'] = component.new('vim', wezterm.nerdfonts.dev_vim, palette.green),
  ['wget'] = component.new('wget', wezterm.nerdfonts.md_arrow_down_box),
  ['yarn'] = component.new('yarn', wezterm.nerdfonts.seti_yarn, palette.blue),
  ['yay'] = component.new('yay', wezterm.nerdfonts.md_pac_man, palette.yellow),
  ['yazi'] = component.new('yazi', wezterm.nerdfonts.md_duck, palette.yellow),
  ['yum'] = component.new('yum', wezterm.nerdfonts.dev_redhat, palette.red),
  ['zsh'] = component.new('zsh', wezterm.nerdfonts.dev_terminal, palette.surface),
}

local function make(pane)
  local foreground_process_name = pane:get_foreground_process_name()
  if foreground_process_name then
    foreground_process_name = foreground_process_name:match('([^/\\]+)[/\\]?$') or foreground_process_name
  end

  -- fallback to the title if the foreground process name is unavailable
  -- Wezterm uses OSC 1/2 escape sequences to guess the process name and set the title
  -- see https://wezfurlong.org/wezterm/config/lua/pane/get_title.html
  -- title defaults to 'wezterm' if another name is unavailable.
  -- Also, when running under WSL, try to use the OSC 1/2 escape sequences as well
  if foreground_process_name == '' or foreground_process_name == 'wslhost.exe' then
    foreground_process_name = pane:get_title()
  end

  -- FIXME: Wezterm wezterm-mux-server does not report the current process for
  -- panes running remotely, hopefully future versions will support this
  -- If the tab active pane contains a non-local domain, use the domain name
  if foreground_process_name == 'wezterm' then
    foreground_process_name = pane:get_domain_name() ~= 'local' and pane:get_domain_name() or 'wezterm'
  end

  return process_to_component[foreground_process_name] or component.new(foreground_process_name, default_icon)
end

return {
  for_window = function(gui_window, pane) return make(pane) end,
  for_tab = function(tab_info) return make(wezterm.mux.get_pane(tab_info.active_pane.pane_id)) end
}
