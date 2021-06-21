# project name and programming language
project('com.github.candiedoperation.parte', 'vala', 'c')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments('--vapidir=' + vapi_dir, language: 'vala')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Widgets/ConnectionStatus.vala',
    'src/Widgets/StatusMessage.vala',
    'src/Widgets/DisplayDiscovery.vala',
    'src/Widgets/DisplayPairRow.vala',
    'src/Utils/GTFStandard.vala',
    'src/Utils/DisplayNetwork.vala',    
    'src/Utils/VolatileDataStore.vala',
    'src/Utils/VirtualDisplayViewer.vala',
    'src/Utils/VirtualDisplayEnvironment.vala',          
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('libhandy-1'),
        dependency('json-glib-1.0'),
        dependency('gtk-vnc-2.0'), #Ubuntu Package libgtk-vnc-2.0-dev
        dependency('libnm'),
        dependency('xcb'),
        dependency('xcb-render'),#DEPENDS ON XCB                
        dependency('xcb-randr'), #DEPENDS ON XCB-RENDER
        meson.get_compiler('c').find_library('libm', required : true), #NEEDED FOR ROUNDING FUNCTIONS TO WORK IN GTFStandard.vala              
    ],
    install: true
)

# Install our .desktop file so the Applications Menu will see it
# install_data(
#     join_paths('data', 'parte.desktop'),
#     install_dir: join_paths(get_option('datadir'), 'applications'),
#     rename: meson.project_name() + '.desktop'
# )

#  Install our .appdata.xml file so AppCenter will see it
# install_data(
#     join_paths('data', 'parte.appdata.xml'),
#     install_dir: join_paths(get_option('datadir'), 'metainfo'),
#     rename: meson.project_name() + '.appdata.xml'
# )

# Install our icons in all the required sizes
#icon_sizes = ['16', '32', '48', '64', '128']

#foreach i : icon_sizes
#    install_data(
#        join_paths('data', i + '.svg'),
#        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
#        rename: meson.project_name() + '.svg'
#    )
#    install_data(
#        join_paths('data', i + '.svg'),
#        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
#        rename: meson.project_name() + '.svg'
#    )
#endforeach
