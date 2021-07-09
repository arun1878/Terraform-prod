output "primary_ip"{ 
    value =  "${aws_cloudformation_stack.network.outputs.PrimaryReplicaNodeIp}"
    }
output "MongoDBServerAccessSecurityGroup"{
    value =  "${aws_cloudformation_stack.network.outputs.MongoDBServerAccessSecurityGroup}"
}