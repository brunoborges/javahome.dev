---
title: Web App | Containers
description: Create a Web App using a container
author: Rob Conery
group: Web
---

###### CHANGE THESE AS NEEDED #######
RG="AZX"
IMAGE="your/dockerhubimage"
APPNAME="AZX_$RANDOM"

#The sku should be one of:
#F1(Free), D1(Shared), B1(Basic Small), B2(Basic Medium), B3(Basic Large), 
#S1(Standard Small), P1(Premium Small), P1V2(Premium V2 Small), 
#PC2 (Premium Container Small), PC3 (Premium Container Medium), 
#PC4 (Premium Container Large).

#accepted values: B1, B2, B3, D1, F1, FREE, P1, P1V2, P2, P2V2, P3, P3V2, PC2, PC3, PC4, S1, S2, S3, SHARED
PLAN=FREE

echo "Creating AppService Plan"
az appservice plan create --name $RG \
                          --resource-group $RG \
                          --sku $PLAN

echo "Creating Web app"
az webapp create --resource-group $RG \
                  --plan $PLAN --name $APPNAME \
                  --deployment-container-image-name $IMAGE

echo "Setting up logging"
#setup logging and monitoring
az webapp log config --application-logging true \
                    --detailed-error-messages true \
                    --web-server-logging filesystem \
                    --level information \
                    --name $APPNAME \
                    --resource-group $RG

echo "Adding logs alias to .env. Invoking this will allow you to see the application logs realtime-ish."

#set an alias for convenience - add to .env
echo "alias logs='az webapp log tail -n $APPNAME -g $RG'" >> .env