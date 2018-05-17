['slack', 'Mail'].each do |klass|
  window class_only: klass do
    remap 'C-b', to: 'Left'
    remap 'C-f', to: 'Right'
    remap 'C-p', to: 'Up'
    remap 'C-n', to: 'Down'

    remap 'M-b', to: 'Ctrl-Left'
    remap 'M-f', to: 'Ctrl-Right'

    remap 'C-a', to: 'Home'
    remap 'C-e', to: 'End'

    remap 'C-k', to: ['Shift-End', 'Ctrl-x']

    remap 'C-h', to: 'BackSpace'
    remap 'C-d', to: 'Delete'
    remap 'M-d', to: 'Ctrl-Delete'

    remap 'C-w', to: ['Ctrl-x']
  end
end

window class_only: 'slack' do
    remap 'C-m', to: 'Shift-KP_Enter'
    remap 'C-o', to: ['Shift-KP_Enter', 'Left']
end

window class_only: 'Mail' do
    remap 'C-m', to: 'KP_Enter'
    remap 'C-o', to: ['KP_Enter', 'Left']
end

window class_only: 'Navigator' do
    remap 'C-q', to: 'Ctrl-Tab'

    remap 'C-n', to: 'Down'
    remap 'M-d', to: 'Ctrl-Delete'
end
