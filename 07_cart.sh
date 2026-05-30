app_name=cart
source ./common.sh
checkroot
app_setup
nodejs_setup
systemd_setup
app_restart
print_total_time