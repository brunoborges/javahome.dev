---
title: PostgreSQL
description: Pushing Azure Database for PostgreSQL to Azure.
group: Database
author: Rob Conery
---

#!/bin/bash

###### SET THESE #####
DATABASE=DB_RANDOM #Will get set to a random value unless already set.
SERVERNAME=$RANDOM #this has to be unique across azure
RG = "AZX" #Your Resource Group - set this in your .env file or here

#Recommend to keep these random, but if you need to change go for it
USER=admin_$RANDOM #set this to whatever you like but it's not something that should be easy
PASS=$(uuidgen) #Again - whatever you like but keep it safe! Better to make it random

#The sku-name parameter value follows the convention {pricing tier}_{compute generation}_{vCores} as in the examples below:
# --sku-name B_Gen5_2 maps to Basic, Gen 5, and 2 vCores.
# --sku-name GP_Gen5_32 maps to General Purpose, Gen 5, and 32 vCores.
# --sku-name MO_Gen5_2 maps to Memory Optimized, Gen 5, and 2 vCores.
#WARNING - this might error out if your region doesn't support the SKU you set here. If it does, execute:
#az group delete -g [resource group] to drop everything and try again
#The SKU below is reasonable for a WP blog, but if you're going to host something more, consider more RAM/Cores
SKU=B_Gen5_1 #this is the cheapest one

echo "Spinning up PostgreSQL $SERVERNAME in group $RG Admin is $USER"

# Create the PostgreSQL service
az postgres server create --resource-group $RG \
    --name $SERVERNAME \
    --admin-user $USER \
    --admin-password $PASS \
    --sku-name $SKU \
    --version 10.0

echo "Guessing your external IP address from ipinfo.io"
IP=$(curl -s ipinfo.io/ip)
echo "Your IP is $IP"

# Open up the firewall so we can access
echo "Popping a hole in firewall for IP address $IP (that's you)"
az postgres server firewall-rule create --resource-group $RG \
        --server $SERVERNAME --name AllowMyIP \
        --start-ip-address $IP --end-ip-address $IP

PG_URL = "postgres://$USER%40$SERVERNAME:$PASS@$SERVERNAME.postgres.database.azure.com"
echo "Creating database..."
psql "$PG_URL/postgres" -c "CREATE DATABASE $DATABASE;"

AZURE_DATABASE_URL="$PG_URL/$DATABASE"
echo "$AZURE_DATABASE_URL" >> .env
echo "Azure database URL added to your .env file. You can now connect to the server by entering this command: "
echo "psql $AZURE_DATABASE_URL"