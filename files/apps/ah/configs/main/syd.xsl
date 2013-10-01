<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns="http://www.w3.org/2005/Atom"
    xmlns:event="http://docs.rackspace.com/core/event"
    exclude-result-prefixes="event map atom xs"
    version="2.0">

    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="tenantIdList" as="xs:string*"  select="('5822189',
                                                                '5823630',
                                                                '5823627',
                                                                '5823628',
                                                                '5823629',
                                                                '5823636',
                                                                '5823637',
                                                                '5823638',
                                                                '5823641',
                                                                '5823647',
                                                                '5823651',
                                                                '5823749',
                                                                '5823750',
                                                                '5823751',
                                                                '5823755',
                                                                '5823771',
                                                                '5823775',
                                                                '5823784',
                                                                '5823785',
                                                                '5823786',
                                                                '5823787',
                                                                '5823796',
                                                                '5823797',
                                                                '5823798',
                                                                '5823799',
                                                                '5823804',
                                                                '5823836',
                                                                '5823838',
                                                                '5824009',
                                                                '5824010',
                                                                '5824012',
                                                                '5824029',
                                                                '5824030',
                                                                '5822399',
                                                                '5820727',
                                                                '5820728',
                                                                '5821633',
                                                                '5821634',
                                                                '5820736',
                                                                '5824084',
                                                                '5820757',
                                                                '5822480',
                                                                '5822481',
                                                                '5824098',
                                                                '5824099',
                                                                '5824100',
                                                                '5824101',
                                                                '5824105',
                                                                '5824114',
                                                                '5824218',
                                                                '5824312',
                                                                '5824279',
                                                                '5824203',
                                                                '5824204',
                                                                '5824210',
                                                                '5824385',
                                                                '5824380',
                                                                '5824381',
                                                                '5824240',
                                                                '5824241',
                                                                '5824242',
                                                                '5824471',
                                                                '5824469',
                                                                '5824470',
                                                                '5824133',
                                                                '5824134',
                                                                '5824135',
                                                                '5831031',
                                                                '5824703',
                                                                '5824706',
                                                                '5824707',
                                                                '5824708',
                                                                '5824709',
                                                                '5824721',
                                                                '5824717',
                                                                '5824719',
                                                                '5824718',
                                                                '5824726',
                                                                '5824748',
                                                                '5824753',
                                                                '5824754',
                                                                '5824769',
                                                                '5824772',
                                                                '5824830',
                                                                '5824831',
                                                                '5824832',
                                                                '5824833',
                                                                '5824838',
                                                                '5824842',
                                                                '5824911',
                                                                '5824913',
                                                                '5824912',
                                                                '5824941',
                                                                '5822969',
                                                                '5823009',
                                                                '5823013',
                                                                '5823014',
                                                                '5823064',
                                                                '5823068',
                                                                '5823137',
                                                                '5823165',
                                                                '5824997',
                                                                '5823159',
                                                                '5823159',
                                                                '5824998',
                                                                '5823203',
                                                                '5823214',
                                                                '5823217',
                                                                '5823230',
                                                                '5823236',
                                                                '5825013',
                                                                '5823239',
                                                                '5823240',
                                                                '5823241',
                                                                '5825017',
                                                                '5825017',
                                                                '5825026',
                                                                '5823245',
                                                                '5823246',
                                                                '5823247',
                                                                '5823248',
                                                                '5823251',
                                                                '5823252',
                                                                '5823266',
                                                                '5823277',
                                                                '5823278',
                                                                '5823293',
                                                                '5823300',
                                                                '5823265',
                                                                '5823319',
                                                                '5823320',
                                                                '5823321',
                                                                '5825141',
                                                                '5825137',
                                                                '5825138',
                                                                '5823393',
                                                                '5823387',
                                                                '5823389',
                                                                '5823413',
                                                                '5823426',
                                                                '5823413',
                                                                '5823431',
                                                                '5823432',
                                                                '5823433',
                                                                '5823434',
                                                                '5823447',
                                                                '5823448',
                                                                '5823549',
                                                                '5823550',
                                                                '5823551',
                                                                '5823552',
                                                                '5823565',
                                                                '5823619',
                                                                '5823620',
                                                                '5823621',
                                                                '5823622',
                                                                '5822180',
                                                                '5822183',                                              
                                                                'StagingUS_67fe0754-6656-475d-8781-2a294ef81a58',
                                                               'StagingUS_6639458b-f6a3-4c93-ad5d-14708fa547f6',
                                                               'StagingUS_3815fd2e-3592-44de-95b5-eb9c40f2adcd',
                                                               'StagingUS_b82f3f7e-7d46-43f9-9fcc-6c28525bc439',
                                                               'StagingUS_782674cd-aecd-42dc-8a2e-560da28827c4',
                                                               'StagingUS_f9b17d69-9683-4de0-a891-86a2c23dfad2',
                                                               'StagingUS_54587111-bee1-456e-8df1-03a0136ad35a',
                                                               'StagingUS_424b9b4e-9f06-44c9-b318-428f1c7c9634',
                                                               'StagingUS_a18922ed-5b2e-4925-87b6-c77c1f59ebee',
                                                               'StagingUS_8de7f33b-2ea6-483e-8513-c245d1ce8fda',
                                                               'StagingUS_b4293cc8-9bb9-405a-b70a-70192220e75d',
                                                               'StagingUS_94449694-cb04-405d-a65c-fd9127f73234',
                                                               'StagingUS_52acb3ee-008b-43c3-be79-ff476a2d088e',
                                                               'StagingUS_93e1893c-2912-403f-b199-8cd0174fb032',
                                                               'StagingUS_a78f5e9c-2185-46b4-a095-d057d0742f0d',
                                                               'StagingUS_7fe2e238-4308-497e-a279-48865faa1580',
                                                               'StagingUS_f2b7e894-89ec-42f5-bcfe-69ba55f3c169',
                                                               'StagingUS_b88deb7f-852e-42fe-91f2-115bf83dab3e',
                                                               'StagingUS_9c6e458f-f66d-40f1-b6b1-4956472f6aac',
                                                               'StagingUS_db21ef23-0da0-4dc1-a5ec-41fdf93e8b2e',
                                                               'StagingUS_75b5aa9d-6b3e-4705-a249-95c70498ae9a',
                                                               'StagingUS_461412af-67d7-4329-a7f8-3187c93d21e7',
                                                               'StagingUS_3cfecbbc-7258-4364-95a2-2612b5f90c26',
                                                               'StagingUS_905da2fd-3d07-49a0-bb4a-64ea74ce67af',
                                                               'StagingUS_5801b11a-02c8-4a95-b564-ea539a6c50df',
                                                               'StagingUS_21a0dfac-44af-4afc-bcc3-2f5b547310fe',
                                                               'StagingUS_ffcc6dfd-d6b3-4215-b087-55e113c19922',
                                                               'StagingUS_de5a81ee-9efb-481f-b718-8e9d5e1dcde7',
                                                               'StagingUS_53a4c2aa-3370-4020-a32a-7dd2d064eede',
                                                               'StagingUS_a02e4964-c2cc-4692-8b83-2d73e45578d3',
                                                               'StagingUS_7676fc53-54aa-4791-8786-accdc3cf5ce8',
                                                               'StagingUS_773bf6f4-cb86-4208-84ef-6b4ff87e7396',
                                                               'StagingUS_b0e706af-bcae-44c5-9fd7-a0ac5b68947b',
                                                               'StagingUS_f8670ffb-cf6a-424f-bcc2-f0d6691d77f9',
                                                               'StagingUS_c2122fcd-90e6-4240-ac6b-5dec6001eb56',
                                                               'StagingUS_710c8bcd-0efc-470e-aebe-7ace3a0331e4',
                                                               'StagingUS_82a99150-fc19-4d99-b874-9acff98ba455',
                                                               'StagingUS_d206525b-f8d1-4605-a10b-3d7757452355',
                                                               'StagingUS_0c234f7b-bee2-45e3-9d06-69ffa4360318',
                                                               'StagingUS_110ceb2f-9d33-4855-8d64-99a063f33198',
                                                               'StagingUS_1d7ba857-c045-497f-a10a-ff63af881675',
                                                               'StagingUS_2eb433b0-0f1a-4c8d-87c0-d87b94c8532e',
                                                               'StagingUS_5bef73e8-0e18-4324-9647-7a049f34511f',
                                                               'StagingUS_bce6d07d-7638-4f78-94f1-bc1ff56fb0c7',
                                                               'StagingUS_0439ab2c-8fd1-4621-a324-68f0a1c0804e',
                                                               'StagingUS_3db6ccc1-4005-49a3-8911-07593072f307',
                                                               'StagingUS_097f9080-7a10-46af-90c0-81b726a34a06',
                                                               'StagingUS_0436eac0-2b88-4808-aba0-e3dc8e19e0e0',
                                                               'StagingUS_57451b51-50e8-4834-a701-2af696fd0e37',
                                                               'StagingUS_31fea5d6-13b5-4667-bde4-2b78fcc73794',
                                                               'StagingUS_05f7e5f5-bedf-4d54-9529-a6593fe32d9a',
                                                               'StagingUS_fc9d4fb2-dfd7-4ec3-90ed-ff85d3a2f974',
                                                               'StagingUS_18af8d6a-11b4-4f27-9c1a-0ee128140dcf',
                                                               'StagingUS_7434e46b-8cb2-44a9-b7cc-be8f3cf0fcf2',
                                                               'StagingUS_17b9e7ee-20f0-40ec-83e4-de5bde2eb6a9',
                                                               'StagingUS_4cc261fe-5079-4167-8ac3-83244acf8177',
                                                               'StagingUS_b015195e-fdc2-4547-8de1-d18bc21b59e3',
                                                               'StagingUS_c6cdc99e-eecd-4212-aadd-5912c8d72ec1',
                                                               'StagingUS_d9d8ebbc-3ecf-421b-b140-fe08c5de1352',
                                                               'StagingUS_fd1004b6-7aa5-4427-a59d-68aea5b14726',
                                                               'StagingUS_0f12c42c-8268-4311-8060-a6cec57a4a4f',
                                                               'StagingUS_b27af916-4fe0-4f8c-8ff6-7b6e80d0d507',
                                                               'StagingUS_df3a3640-7f14-43d7-b9d7-e803b920999b',
                                                               'StagingUS_fdd3ac57-4979-474d-b98e-c1ba2b3beaea',
                                                               'StagingUS_56e3cb5b-a4da-45e3-a069-958ff0cda6ea',
                                                               'StagingUS_1c425f12-ba71-4dea-a04a-e4d0db20ccb5',
                                                               'StagingUS_fa07afcf-59b9-44f2-8867-9320dd804901',
                                                               'StagingUS_4041efba-1a73-46d2-bcea-25422b76348a',
                                                               'StagingUS_8ec8f14f-bf66-45e9-8a8f-0f1cc92ae737',
                                                               'StagingUS_e77b8b96-218d-4194-b7fc-f10c151ec7e8',
                                                               'StagingUS_06d6c235-abe1-4829-bf46-3eac5107c10d',
                                                               'StagingUS_068014ee-2305-44ab-bb54-8044a42954c6',
                                                               'StagingUS_12292e96-ed8e-4bf5-add4-9b515973a197',
                                                               'StagingUS_fa7dfa8d-8f09-4cc0-a699-ffcb6e98f648',
                                                               'StagingUS_b4b26ea2-5ffd-45a0-a1eb-8b08308604a6',
                                                               'StagingUS_a8602155-aeac-42b8-bec3-0782a49a0238',
                                                               'StagingUS_60b89540-2fb7-41d1-b9bb-94230100b68b',
                                                               'StagingUS_8879363f-bd3e-481a-945f-c55fecf8c7f2',
                                                               'StagingUS_e76165fb-73db-414e-9a60-2b353a258926',
                                                               'StagingUS_9e6f594e-4a5f-4885-8eda-9a37bd2116d3',
                                                               'StagingUS_a2406dd4-617f-45af-9901-525a83908ce0',
                                                               'StagingUS_92b23436-ac9d-40ba-b3d1-92a878775233',
                                                               'StagingUS_8a97d06b-d80d-43ac-ada0-385531720b17',
                                                               'StagingUS_443a8108-49d4-4b61-9934-83145cf1d9ff',
                                                               'StagingUS_264aca1f-50c1-47fa-852f-07cfef220043',
                                                               'StagingUS_e0f578c8-530c-4ce8-a793-15303d37c166',
                                                               'StagingUS_31368fd1-7638-4eda-bc30-dd7aa1b1869b',
                                                               'StagingUS_47500fa0-1d89-4201-80b2-3d536e82c052',
                                                               'StagingUS_99be7189-3d70-4ca8-aa4f-abe2974ef423',
                                                               'StagingUS_d6b34008-9dd8-4198-83ec-82a6c4853236',
                                                               'StagingUS_0f6b106f-c8c4-4bad-ac75-5dc6aad34981',
                                                               'StagingUS_17520bae-db57-4aac-b98f-6899550abe0e',
                                                               'StagingUS_05c0728d-2909-4745-8b7f-8bb6b931d3c8',
                                                               'StagingUS_6ca398a2-74e8-4885-b86a-84ec1202ebc9',
                                                               'StagingUS_8203cbf0-5eb1-4127-b2f4-a624db22844b',
                                                               'StagingUS_c2a3cea8-8626-408e-a28c-b5519b3e90ad',
                                                               'StagingUS_f0d2312d-32ad-425f-8978-4711300bae81',
                                                               'StagingUS_d6954e05-e318-486c-93bd-d0bbaabeed85',
                                                               'StagingUS_68384c3e-15ed-47bf-ba7c-1b79aa639b4c',
                                                               'StagingUS_9ca3f95f-09aa-42cf-9ae0-df264356d393',
                                                               'StagingUS_a758a120-012e-49b5-979a-1831c6a1175b',
                                                               'StagingUS_5835686d-e328-47e0-851a-4f5fb8119de0',
                                                               'StagingUS_c6b52631-32db-41c5-8459-620e7ffdf29f',
                                                               'StagingUS_c6b52631-32db-41c5-8459-620e7ffdf29f',
                                                               'StagingUS_b65f9d3b-f213-4ef1-9397-2cc8ae359b00',
                                                               'StagingUS_02a67c7d-a365-407e-84f4-52a2febadab9',
                                                               'StagingUS_5a70aeaf-265a-4cbd-b34c-39e9109d3cfb',
                                                               'StagingUS_08371f2d-4ae5-4f8c-9d48-820b85c71584',
                                                               'StagingUS_9fdc1baf-5a43-426a-b8cc-2440d8eb4a28',
                                                               'StagingUS_c487a91e-8386-40f9-a30f-0e4b1b56deb7',
                                                               'StagingUS_76bb9084-57b3-4297-b3db-570d9f1eb38d',
                                                               'StagingUS_69e24de9-1b1c-40e3-b9dd-8f9da32946b5',
                                                               'StagingUS_b147ff66-2d10-423f-9c72-1c567726c141',
                                                               'StagingUS_ef374e42-3139-4723-adb6-be36862a0e83',
                                                               'StagingUS_8dee5226-6e5d-42b4-ab64-193bb1f2e062',
                                                               'StagingUS_8dee5226-6e5d-42b4-ab64-193bb1f2e062',
                                                               'StagingUS_e31611e5-fa3f-4a51-9de0-ba288b56e60b',
                                                               'StagingUS_96ffe7d4-6da1-4f76-9de9-22ba08eea67e',
                                                               'StagingUS_5a246607-77f1-4d6b-9335-9cce88e711c0',
                                                               'StagingUS_30d61ae5-521b-4195-86a6-d5c262a26dea',
                                                               'StagingUS_cefc7b3f-d078-4255-847f-9842e5f98753',
                                                               'StagingUS_df684a01-6cfd-4063-b280-930f8247f991',
                                                               'StagingUS_4fdd01ed-66d9-4952-adfd-3657c4331947',
                                                               'StagingUS_0c951913-26d0-46f9-a878-812dd6d3d7a1',
                                                               'StagingUS_c057bd1d-3064-4f37-bb15-a46395415154',
                                                               'StagingUS_56ff4d80-259f-403a-a448-2ea5f5bd1f1c',
                                                               'StagingUS_3614ec52-e65d-4726-8c97-656fb27e5ee7',
                                                               'StagingUS_b4a6b5d7-9acc-4579-b255-9f4a6aa7a880',
                                                               'StagingUS_6864b709-fad6-46c0-8d3c-00323b2e4c7c',
                                                               'StagingUS_46d0fd27-e0e0-43c7-97fd-e81871596d4f',
                                                               'StagingUS_36e4829d-661d-46da-a5b5-cc602663edb7',
                                                               'StagingUS_e6c05adf-43fb-4ef6-844a-62ae97ccac8b',
                                                               'StagingUS_b0e241eb-3e3b-4c17-a0b6-a683abd96afa',
                                                               'StagingUS_0983df83-541e-4fc8-b23f-5a210a893c4e',
                                                               'StagingUS_c4b243d2-6b09-4ff0-a14c-e26dc2cca96a',
                                                               'StagingUS_1d60f15b-f141-4d64-9b57-7bd59bebb567',
                                                               'StagingUS_dc0636df-9e4c-4169-85ff-5fc17b5aab28',
                                                               'StagingUS_660cf389-2343-4f77-81f3-eced08402aa8',
                                                               'StagingUS_5345e1f6-147c-48d0-a3de-618f5c36c5a4',
                                                               'StagingUS_d1469c86-ff64-43c6-aef2-1dce759c195e',
                                                               'StagingUS_5345e1f6-147c-48d0-a3de-618f5c36c5a4',
                                                               'StagingUS_23287091-50e7-45a0-8047-f756b5d3f4c9',
                                                               'StagingUS_8ce85ada-8179-4878-a5e3-5fc701a00377',
                                                               'StagingUS_bd1cea73-1970-4272-9b14-4ebe273dbebc',
                                                               'StagingUS_558b27de-7cb3-439e-aeb9-9527582d3e21',
                                                               'StagingUS_85e0d618-2064-4758-9499-17babe9db7d2',
                                                               'StagingUS_7b76a79b-ffad-4bda-a716-ff3b80cd82e6',
                                                               'StagingUS_7508cc43-610a-483f-a9e2-4810004d4f22',
                                                               'StagingUS_a0d2e77b-d289-4991-a13e-c96d6f38a8d7',
                                                               'StagingUS_bf592120-2f4e-46fc-893a-7a905da7af19',
                                                               'StagingUS_7ced65de-c498-4ed9-8d51-9037a770b750',
                                                               'StagingUS_62fe742c-c9eb-4dd7-97a5-dfab23065c0d',
                                                               'StagingUS_3e01f909-8696-45d5-876a-f35fe2c311d0',
                                                               'StagingUS_2975eada-a638-48d0-93f2-5461151e3316',
                                                               'StagingUS_5b7232e1-7f7d-4f49-b01d-d6ddd72bd6f9',
                                                               'StagingUS_e9e96347-4a90-4140-84f4-4c229501ff80',
                                                               'StagingUS_29c5ab32-04d0-4fa7-b93c-2f55d0a0c73d',
                                                               'StagingUS_a39f3408-80dc-409c-beb8-1202e08552e8')"/>

    <xsl:variable name="namespaceList" as="xs:string*"  select="('http://docs.rackspace.com/usage/dbaas',
                                                                'http://docs.rackspace.com/usage/cbs',
                                                                'http://docs.rackspace.com/usage/cbs/snapshot',
                                                                'http://docs.rackspace.com/usage/lbaas')"/>

    <xsl:variable name="resourceNameMatch" as="xs:string" select="'^[a-m,A-M,0-5].*$'"/>
    <xsl:variable name="hostnameMatch" as="xs:string" select="'.*&#34;hostname&#34;\s*:\s*&#34;([^&#34;]*)&#34;.*$'"/>
    <xsl:variable name="tenantIdMatch" as="xs:string" select="'.*&#34;tenant_id&#34;\s*:\s*&#34;([^&#34;]*)&#34;.*$'"/>
    <xsl:variable name="nameMatch" as="xs:string" select="'.*&#34;name&#34;\s*:\s*&#34;([^&#34;]*)&#34;.*$'"/>
    <xsl:variable name="ownerMatch" as="xs:string" select="'.*&#34;owner&#34;\s*:\s*&#34;([^&#34;]*)&#34;.*$'"/>

    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Handle standard event -->
    <xsl:template match="event:event">
      <xsl:choose>  
          <xsl:when test="namespace-uri(*:product) = $namespaceList and @tenantId = $tenantIdList and matches(@resourceName, $resourceNameMatch)">
           <xsl:copy>
              <xsl:attribute name="region">SYD</xsl:attribute>
              <xsl:attribute name="dataCenter">SYD2</xsl:attribute>
              <xsl:apply-templates
                select="@*[(local-name() != 'region') and
                           (local-name() != 'dataCenter')] | node()"/>
           </xsl:copy>
        </xsl:when>
          <xsl:when test="namespace-uri(*:product) = 'http://docs.rackspace.com/usage/cloudbackup/license' and @tenantId = $tenantIdList and matches(*:product/@serverID, $resourceNameMatch)">
            <xsl:copy>
                <xsl:attribute name="region">SYD</xsl:attribute>
                <xsl:attribute name="dataCenter">SYD2</xsl:attribute>
                <xsl:apply-templates
                    select="@*[(local-name() != 'region') and
                    (local-name() != 'dataCenter')] | node()"/>
            </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!-- Compute JSON Event -->
    <xsl:template match="atom:entry[atom:content/@type = 'application/json' and atom:category/@term = 'compute.instance.exists']">
        <xsl:call-template name="TransformJSONEvent">
            <xsl:with-param name="id" select="replace(atom:content, $tenantIdMatch, '$1')"/>
            <xsl:with-param name="resourceName" select="replace(atom:content, $hostnameMatch, '$1')"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Image JSON Event -->
    <xsl:template match="atom:entry[atom:content/@type = 'application/json' and atom:category/@term = ('image.upload', 'image.delete')]">
        <xsl:call-template name="TransformJSONEvent">
            <xsl:with-param name="id" select="replace(atom:content, $ownerMatch, '$1')"/>
            <xsl:with-param name="resourceName" select="replace(atom:content, $nameMatch, '$1')"/>
        </xsl:call-template>
    </xsl:template>

    <!--
        Does transfrom of JSON event given tenatID and resourceName.
    -->
    <xsl:template name="TransformJSONEvent">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="resourceName" as="xs:string"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="$id = $tenantIdList and matches($resourceName, $resourceNameMatch)">
                    <!--
                        We got a match on the ID so create DATACENTER and REGION.
                    -->
                    <category term="DATACENTER=syd2"/>
                    <category term="REGION=syd"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--
                        No match so copy region and datacenter.
                    -->
                    <xsl:copy-of select="atom:category[starts-with(@term,'DATACENTER')]"/>
                    <xsl:copy-of select="atom:category[starts-with(@term,'REGION')]"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()" mode="noRGNCAT"/>
        </xsl:copy>
    </xsl:template>


    <!--
        Don't automatically copy DATA and REGION, when transforming JSON events.
    -->

    <xsl:template match="atom:category[starts-with(@term,'DATACENTER')]" mode="noRGNCAT"/>
    <xsl:template match="atom:category[starts-with(@term,'REGION')]" mode="noRGNCAT"/>

</xsl:stylesheet>
