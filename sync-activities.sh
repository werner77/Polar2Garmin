#!/bin/sh

polar_username="<your polar user>"
polar_password="<your polar password>"
garmin_username="<your garmin user>"
garmin_password="<your garmin password>"
age="<age in years>"
weight="<weight in kg>"
gender="<MALE or FEMALE>"
timezone="<TIMEZONE, for example CET>"

tmpdir="./tmp"
gpxdir="./polar"
tcxdir="./tcx"

mkdir -p "${tmpdir}"
mkdir -p "${gpxdir}"
mkdir -p "${tcxdir}"
rm -rf "${tmpdir}/*"
rm -rf "${gpxdir}/*"

curl -c "${tmpdir}/cookies.txt" --data-urlencode "email=${polar_username}" --data-urlencode "password=${polar_password}" --data-urlencode ".action=login" --data-urlencode "tz=-60" https://www.polarpersonaltrainer.com/index.ftl 
curl -b "${tmpdir}/cookies.txt" -c "${tmpdir}/cookies.txt" "https://www.polarpersonaltrainer.com/user/liftups/feed.ftl?feedFilterItems=target&feedFilterItems=result&feedFilterItems=message&feedFilterItems=fitnessdata&feedFilterItems=challenge" | grep -o "analyze.ftl?id=[0-9]*" | cut -c 16-30 > "${tmpdir}/activities.txt"
sort -u "${tmpdir}/activities.txt" > "${tmpdir}/sorted-activities.txt"

for activityId in `cat ${tmpdir}/sorted-activities.txt`
do

if [ ! -f "${tcxdir}/done/${activityId}.tcx" ]; then

    curl -b "${tmpdir}/cookies.txt" -c "${tmpdir}/cookies.txt" --data ".action=gpx&items.0.item=${activityId}&items.0.itemType=OptimizedExercise" https://www.polarpersonaltrainer.com/user/calendar/index.gpx > "${gpxdir}/${activityId}.gpx"

    curl -b "${tmpdir}/cookies.txt" -c "${tmpdir}/cookies.txt" --data ".action=export&items.0.item=${activityId}&items.0.itemType=OptimizedExercise&.filename=training.xml" https://www.polarpersonaltrainer.com/user/calendar/index.jxml > "${gpxdir}/${activityId}.xml"

    ./PolarConverter -t "${gpxdir}/${activityId}.xml" -x "${gpxdir}/${activityId}.gpx" -a "${age}" -w "${weight}" -g "${gender}" -z "${timezone}" "${tcxdir}/${activityId}.tcx"

else
	
    echo "Activity ${activityId} was ignored because it has already been processed in the past"

fi

done

rm -rf "${tmpdir}"

cd "${tcxdir}"
mkdir -p "done"

for tcxfile in *.tcx
do

if [ ! -f done/${tcxfile} ]; then

    echo "Uploading activity from file ${tcxfile}"

    [[ $(gupload.py -l ${garmin_username} ${garmin_password} ${tcxfile}) =~ "SUCCESS" ]] && mv ${tcxfile} done
else

    echo "Activity from file ${tcxfile} was already uploaded"
    rm ${tcxfile}
fi

done

cd -
