@merge_key1, @merge_key2 = "key-one", "key-two"

def merge_em(g1, g2)
  case g1
  when Array
    g1.size.times {|i| merge_em(g1[i], g2[i])}
  when Hash
    g1.keys.each do |k|
      v = g1[k]
      if (Hash === v || (Array === v && !v.empty?)) 
        merge_em(v, g2[k])
      else
        g1[k] = {@merge_key1 => v, @merge_key2 => g2[k]}
      end
    end
  end
end

#h = Marshal.load(Marshal.dump(h1))
h = {"actions"=>[{"causes"=>[{"shortDescription"=>"Started by user gabe.westmaas", "userId"=>"gabe.westmaas", "userName"=>"gabe.westmaas"}]}, nil], "artifacts"=>[], "building"=>false, "description"=>nil, "duration"=>616063, "estimatedDuration"=>616063, "executor"=>nil, "fullDisplayName"=>"Gabe-Compute-Preprod-Smoke #1", "id"=>"2014-01-07_16-23-27", "keepLog"=>false, "number"=>1, "result"=>"FAILURE", "timestamp"=>1389133407000, "url"=>"https://jenkins.ohthree.com/job/Gabe-Compute-Preprod-Smoke/1/", "builtOn"=>"jenkins-slave1.ohthree.com", "changeSet"=>{"items"=>[], "kind"=>nil}, "culprits"=>[]}
h2 = {"actions"=>[{"causes"=>[{"shortDescription"=>"Started by user gabe.westmaas", "userId"=>"gabe.westmaas", "userName"=>"gabe.westmaas"}]}, nil], "artifacts"=>[], "building"=>false, "description"=>nil, "duration"=>646063, "estimatedDuration"=>646063, "executor"=>nil, "fullDisplayName"=>"Gabe-Compute-Preprod-Smoke #4", "id"=>"2013-04-07_46-23-27", "keepLog"=>false, "number"=>4, "result"=>"SUCCESS", "timestamp"=>4389433407000, "url"=>"https://jenkins.ohthree.com/job/Gabe-Compute-Preprod-Smoke/4/", "builtOn"=>"jenkins-slave4.ohthree.com", "changeSet"=>{"items"=>[], "kind"=>nil}, "culprits"=>[]}
h3 = {"actions"=>[{"causes"=>[{"shortDescription"=>"Started by user gabe.westmaas", "userId"=>"gabe.westmaas", "userName"=>"gabe.westmaas"}]}, nil], "artifacts"=>[], "building"=>false, "description"=>nil, "duration"=>646063, "estimatedDuration"=>646063, "executor"=>nil, "fullDisplayName"=>"Gabe-Compute-Preprod-Smoke #4", "id"=>"2013-04-07_46-23-27", "keepLog"=>false, "number"=>4, "result"=>"SUCCESS", "timestamp"=>4389433407000, "url"=>"https://jenkins.ohthree.com/job/Gabe-Compute-Preprod-Smoke/4/", "builtOn"=>"jenkins-slave4.ohthree.com", "changeSet"=>{"items"=>[], "kind"=>nil}, "culprits"=>[]}
h4 = merge_em(h, h2)
h4 = merge_em(h, h3)
p h

