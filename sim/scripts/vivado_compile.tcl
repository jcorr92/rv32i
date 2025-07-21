# Get env vars
set src_dir $env(SRC_DIR)
set tb_file $env(TB_FILE)

# Compile sources with xvlog
exec xvlog -sv -f

# Elaborate design and create snapshot with xelab
exec xelab $top_module -debug typical -snapshot ${tb_file}_snapshot

