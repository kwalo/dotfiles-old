function! LoadRope()
python << EOF
import os.path
import sys
modules = os.path.join(os.environ['HOME'], '.vim', 'ftplugin', 'python')
sys.path.append(modules)
import ropevim
EOF
endfunction

call LoadRope()
