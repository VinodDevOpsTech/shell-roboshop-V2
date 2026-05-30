app_name=catalogue
source ./common.sh
checkroot
app_setup
nodejs_setup
systemd_setup



cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Added Mongo repo" 

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installed MongoDB client"

INDEX=$(mongosh --host mongodb.maxdevopstech.online --eval 'db.getMongo().getDBNames().indexOf("$app_name")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.maxdevopstech.online </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "Load Products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi
print_total_time