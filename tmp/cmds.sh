# Check registered in ambari server blueprints
curl -u admin:admin -X GET http://hdpkub:8080/api/v1/blueprints

# Check installed clusters
curl -u admin:admin -X GET http://hdpkub:8080/api/v1/clusters

# Take a blueprint from working cluster named "AutoCluster1"
curl -u admin:admin -X GET http://hdpkub:8080/api/v1/clusters/AutoCluster1?format=blueprint

# Register blueprint named "DockerClusterBP" described in bp.json
curl -u admin:admin -H "X-Requested-By:MyCompany" -X POST http://hdpkub:8080/api/v1/blueprints/DockerClusterBP?validate_topology=false -d @bp.json
