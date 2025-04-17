output "root_record_fqdn" {
  value = aws_route53_record.root.fqdn
}

output "www_record_fqdn" {
  value = aws_route53_record.www.fqdn
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}
