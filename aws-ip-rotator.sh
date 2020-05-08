#!/usr/bin/env bash

case $1 in
    'start' )
        apt-get install -y awscli
        SCHEDULE='*/10 * * * *' # every ten minutes
        (crontab -l 2> /dev/null; echo "$SCHEDULE $(pwd)/$(basename $0)") | crontab - ;;
    'stop' )
        crontab -l | grep -v $(basename $0) | crontab - ;;
    *)
        INSTANCE=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
        OLD_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
  OLD_ALLOCATION_ID=$(aws ec2 describe-addresses --public-ips $OLD_IP --query "Addresses[0].AllocationId" | tr -d '"')
        NEW_IP=$(aws ec2 allocate-address --query PublicIp | tr -d '"')
        echo ''
        echo "Old ALLOCATOIN_ID: $OLD_ALLOCATION_ID"
        echo "Old IP: $OLD_IP"
        echo "New IP: $NEW_IP"
        echo ''
        echo 'Associating new IP...'
        aws ec2 associate-address --instance-id $INSTANCE --public-ip $NEW_IP
        echo 'Releasing old IP...'
        aws ec2 release-address --allocation-id $OLD_ALLOCATION_ID
esac
