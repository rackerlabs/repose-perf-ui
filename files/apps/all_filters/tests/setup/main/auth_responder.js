var express = require('express');
var libxmljs = require('libxmljs');
require('date-utils');

var app = express();

app.post('/tokens', function(req, res){
  var body = req.body;
  res.set('Content-Type','application/xml');
  res.send(200, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><access xmlns="http://docs.openstack.org/identity/api/v2.0" xmlns:os-ksadm="http://docs.openstack.org/identity/api/ext/OS-KSADM/v1.0" xmlns:os-ksec2="http://docs.openstack.org/identity/api/ext/OS-KSEC2/v1.0" xmlns:rax-ksqa="http://docs.rackspace.com/identity/api/ext/RAX-KSQA/v1.0" xmlns:rax-kskey="http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0"><token id="this-is-the-admin-token" expires="2013-08-03T19:46:54Z"><tenant id="this-is-the-admin-tenant" name="this-is-the-admin-tenant"/></token><user xmlns:rax-auth="http://docs.rackspace.com/identity/api/ext/RAX-AUTH/v1.0" id="67890" name="admin_username" rax-auth:defaultRegion="the-default-region"><roles><role id="684" name="compute:default" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000001" tenantId="12345"/><role id="5" name="object-store:default" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000002" tenantId="12345"/></roles></user><serviceCatalog><service type="rax:object-cdn" name="cloudFilesCDN"><endpoint region="DFW" tenantId="this-is-the-admin-tenant" publicURL="https://cdn.stg.clouddrive.com/v1/this-is-the-admin-tenant"/><endpoint region="ORD" tenantId="this-is-the-admin-tenant" publicURL="https://cdn.stg.clouddrive.com/v1/this-is-the-admin-tenant"/></service><service type="object-store" name="cloudFiles"><endpoint region="ORD" tenantId="this-is-the-admin-tenant" publicURL="https://storage.stg.swift.racklabs.com/v1/this-is-the-admin-tenant" internalURL="https://snet-storage.stg.swift.racklabs.com/v1/this-is-the-admin-tenant"/><endpoint region="DFW" tenantId="this-is-the-admin-tenant" publicURL="https://storage.stg.swift.racklabs.com/v1/this-is-the-admin-tenant" internalURL="https://snet-storage.stg.swift.racklabs.com/v1/this-is-the-admin-tenant"/></service></serviceCatalog></access>');
});

app.get('/tokens/:token_id', function(req,res){
  var token = req.params.token_id;
  var tempDate = new Date();
  
  var date = tempDate.addDays(1).toFormat('YYYY-MM-DDTHH24:MI:SSZ');
  if(token.indexOf('valid-racker-token') == 0){
    res.send(200); 
  }
  if(token.indexOf('valid-observer-token') == 0){
    var user_id = token.substr('valid-observer-token'.length);
    res.set('Content-Type','application/xml');
    res.send(200,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><access xmlns="http://docs.openstack.org/identity/api/v2.0" xmlns:os-ksadm="http://docs.openstack.org/identity/api/ext/OS-KSADM/v1.0" xmlns:os-ksec2="http://docs.openstack.org/identity/api/ext/OS-KSEC2/v1.0" xmlns:rax-ksqa="http://docs.rackspace.com/identity/api/ext/RAX-KSQA/v1.0" xmlns:rax-kskey="http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0"><token id="' + token + '" expires="' + date + '"><tenant id="this-is-the-tenant" name="this-is-the-tenant"/></token><user xmlns:rax-auth="http://docs.rackspace.com/identity/api/ext/RAX-AUTH/v1.0" id="' + user_id + '" name="username" rax-auth:defaultRegion="the-default-region"><roles><role id="684" name="compute:default" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000001" tenantId="' + user_id + '"/><role id="685" name="observer" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000001" tenantId="' + user_id + '"/><role id="5" name="object-store:default" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000002" tenantId="' + user_id + '"/></roles></user><serviceCatalog><service type="rax:object-cdn" name="cloudFilesCDN"><endpoint region="DFW" tenantId="this-is-the-tenant" publicURL="https://cdn.stg.clouddrive.com/v1/this-is-the-tenant"/><endpoint region="ORD" tenantId="this-is-the-tenant" publicURL="https://cdn.stg.clouddrive.com/v1/this-is-the-tenant"/></service><service type="object-store" name="cloudFiles"><endpoint region="ORD" tenantId="this-is-the-tenant" publicURL="https://storage.stg.swift.racklabs.com/v1/this-is-the-tenant" internalURL="https://snet-storage.stg.swift.racklabs.com/v1/this-is-the-tenant"/><endpoint region="DFW" tenantId="this-is-the-tenant" publicURL="https://storage.stg.swift.racklabs.com/v1/this-is-the-tenant" internalURL="https://snet-storage.stg.swift.racklabs.com/v1/this-is-the-tenant"/></service></serviceCatalog></access>');
  }
  if(token.indexOf('valid-admin-token') == 0){
    var user_id = token.substr('valid-admin-token'.length);
    res.set('Content-Type','application/xml');
    res.send(200,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><access xmlns="http://docs.openstack.org/identity/api/v2.0" xmlns:os-ksadm="http://docs.openstack.org/identity/api/ext/OS-KSADM/v1.0" xmlns:os-ksec2="http://docs.openstack.org/identity/api/ext/OS-KSEC2/v1.0" xmlns:rax-ksqa="http://docs.rackspace.com/identity/api/ext/RAX-KSQA/v1.0" xmlns:rax-kskey="http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0"><token id="' + token + '" expires="' + date + '"><tenant id="this-is-the-tenant" name="this-is-the-tenant"/></token><user xmlns:rax-auth="http://docs.rackspace.com/identity/api/ext/RAX-AUTH/v1.0" id="' + user_id + '" name="username" rax-auth:defaultRegion="the-default-region"><roles><role id="684" name="compute:default" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000001" tenantId="' + user_id + '"/><role id="685" name="admin" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000001" tenantId="' + user_id + '"/><role id="5" name="object-store:default" description="A Role that allows a user access to keystone Service methods" serviceId="0000000000000000000000000000000000000002" tenantId="' + user_id + '"/></roles></user><serviceCatalog><service type="rax:object-cdn" name="cloudFilesCDN"><endpoint region="DFW" tenantId="this-is-the-tenant" publicURL="https://cdn.stg.clouddrive.com/v1/this-is-the-tenant"/><endpoint region="ORD" tenantId="this-is-the-tenant" publicURL="https://cdn.stg.clouddrive.com/v1/this-is-the-tenant"/></service><service type="object-store" name="cloudFiles"><endpoint region="ORD" tenantId="this-is-the-tenant" publicURL="https://storage.stg.swift.racklabs.com/v1/this-is-the-tenant" internalURL="https://snet-storage.stg.swift.racklabs.com/v1/this-is-the-tenant"/><endpoint region="DFW" tenantId="this-is-the-tenant" publicURL="https://storage.stg.swift.racklabs.com/v1/this-is-the-tenant" internalURL="https://snet-storage.stg.swift.racklabs.com/v1/this-is-the-tenant"/></service></serviceCatalog></access>');

  }

  res.send(404);
});

app.get('/tokens/:token_id/endpoints', function(req,res){
  var token = req.params.token_id;
  var tempDate = new Date();
  
  var date = tempDate.addDays(1).toFormat('YYYY-MM-DDTHH24:MI:SSZ');
  if(token.indexOf('valid-racker-token') == 0){
    res.send(200); 
  }
  if(token.indexOf('valid-observer-token') == 0){
    var user_id = token.substr('valid-observer-token'.length);
    res.set('Content-Type','application/xml');
    res.send(200,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><endpoints xmlns="http://docs.openstack.org/identity/api/v2.0"           xmlns:ns2="http://www.w3.org/2005/Atom"           xmlns:os-ksadm="http://docs.openstack.org/identity/api/ext/OS-KSADM/v1.0"           xmlns:rax-ksqa="http://docs.rackspace.com/identity/api/ext/RAX-KSQA/v1.0"           xmlns:rax-kskey="http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0"           xmlns:os-ksec2="http://docs.openstack.org/identity/api/ext/OS-KSEC2/v1.0"           xmlns:rax-auth="http://docs.rackspace.com/identity/api/ext/RAX-AUTH/v1.0"><endpoint id="1" tenantId="this-is-the-tenant" name="nova:this-is-the-tenant" type="compute:default" region="the-default-region" publicURL="http://localhost:8080/' + user_id + '" internalURL="http://localhost:8080/' + user_id + '" adminURL="http://localhost:8080/' + user_id + '" /><endpoint id="2" tenantId="this-is-the-tenant" name="swift:this-is-the-tenant" type="admin" region="the-default-region1" publicURL="http://localhost:8080/' + user_id + '" internalURL="http://localhost:8080/' + user_id + '" adminURL="http://localhost:8080/' + user_id + '" /><endpoint id="3" tenantId="this-is-the-tenant" name="files:this-is-the-tenant" type="object-store:default" region="the-default-region2" publicURL="http://localhost:8080/' + user_id + '" internalURL="http://localhost:8080/' + user_id + '" adminURL="http://localhost:8080/' + user_id + '" /></endpoints>');
  }
  if(token.indexOf('valid-admin-token') == 0){
    var user_id = token.substr('valid-admin-token'.length);
    res.set('Content-Type','application/xml');
    res.send(200,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><endpoints xmlns="http://docs.openstack.org/identity/api/v2.0"           xmlns:ns2="http://www.w3.org/2005/Atom"           xmlns:os-ksadm="http://docs.openstack.org/identity/api/ext/OS-KSADM/v1.0"           xmlns:rax-ksqa="http://docs.rackspace.com/identity/api/ext/RAX-KSQA/v1.0"           xmlns:rax-kskey="http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0"           xmlns:os-ksec2="http://docs.openstack.org/identity/api/ext/OS-KSEC2/v1.0"           xmlns:rax-auth="http://docs.rackspace.com/identity/api/ext/RAX-AUTH/v1.0"><endpoint id="1" tenantId="this-is-the-tenant" name="nova:this-is-the-tenant" type="compute:default" region="the-default-region" publicURL="http://localhost:8080/' + user_id + '" internalURL="http://localhost:8080/' + user_id + '" adminURL="http://localhost:8080/' + user_id + '" /><endpoint id="2" tenantId="this-is-the-tenant" name="swift:this-is-the-tenant" type="admin" region="the-default-region1" publicURL="http://localhost:8080/' + user_id + '" internalURL="http://localhost:8080/' + user_id + '" adminURL="http://localhost:8080/' + user_id + '" /><endpoint id="3" tenantId="this-is-the-tenant" name="files:this-is-the-tenant" type="object-store:default" region="the-default-region2" publicURL="http://localhost:8080/' + user_id + '" internalURL="http://localhost:8080/' + user_id + '" adminURL="http://localhost:8080/' + user_id + '" /></endpoints>');
  }

  res.send(404);

});

app.get('/users/:user_id/RAX-KSGRP', function(req,res){
  res.set('Content-Type','application/xml');
  var user = req.params.user_id;
  res.send(200,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><groups xmlns="http://docs.rackspace.com/identity/api/ext/RAX-KSGRP/v1.0"><group id="0" name="Default"><description>Default Limits</description></group></groups>');
});

app.get('/', function(req, res){
  res.send('hello world');
});

app.listen(9090);
