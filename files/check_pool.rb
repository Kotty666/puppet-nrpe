#!/usr/bin/ruby

require 'optparse'
require 'pp'

options    = {}
list       = {}
usage      = []
media_stat = []
ex         = 3

OptionParser.new { |opts|
  opts.banner    = 'Usage: check_pool.rb [options]'
  options        = {
    pool: 'ceph_ma._.weeks',
    warning: 75,
    critical: 90,
    filter: [],
  }

  opts.on('-p', '--pool <pool_name>', 'name of pool to check (regex possible)') { |v| options[:pool] = v }
  opts.on('-w', '--warning <percent warning>', 'Percent space raising warning') { |v| options[:warning] = v }
  opts.on('-c', '--critical <percent critical>', 'Percent space raising critical') { |v| options[:critical] = v }
  opts.on('-f', '--filter <filter string>', 'string to group pools') { |v| options[:filter] << v }
  opts.on_tail('-h', '--help', 'Show this help message') do
    puts opts
    exit 3
  end
}.parse!

def get_info(pool = '')
  if pool.empty?
    puts 'no poolname given!'
    exit 3
  else
    info = `/opt/omni/bin/omnimm -show_pool #{ pool }`
    used = info.match(%r{Blocks used \[MB\]    : (\d+)})[1]
    size = info.match(%r{Blocks total \[MB\]   : (\d+)})[1]
    fp   = info.match(%r{.*Uses free pool \((.*)\).*}).nil? ? '' : (info.match(%r{.*Uses free pool \((.*)\).*})[1]).to_s

    {
      size: (size.to_f / 1024),
      used: (used.to_f / 1024),
      freepool: fp.to_s,
    }
  end
end

def get_media_info(pool = '')
  if pool.empty?
    puts 'no poolname given!'
    exit 3
  else
    media      = {}
    id         = []
    label      = []
    status     = []
    protection = []

    `/opt/omni/bin/omnimm -list_pool #{ pool } -detail | awk '$0 ~ /Medium identifier|Medium label|Status|Protected/'`.split("\n").each do |info|
      id         << info.match(%r{Medium identifier : (.+)\s+})[1].squeeze(' ') if info =~ %r{Medium identifier}
      label      << info.match(%r{Medium label             : (.+)\s+$})[1].squeeze(' ') if info =~ %r{Medium label}
      status     << info.match(%r{Status                   : (.+)\s+$})[1].squeeze(' ') if info =~ %r{Status}
      protection << info.match(%r{Protected                : (.+)})[1].squeeze(' ') if info =~ %r{Protected}
    end

    label.each_with_index do |l, i|
      media[l.strip] = {
        id: id[i].strip,
        status: status[i].strip,
        protection: protection[i].strip,
      }
    end
  end
  media
end

def get_usage(pool = '', total = 0.00, used = 0.00, warn = 75, crit = 95)
  up = (100.00 * used / total).round

  "Pool \"#{pool}\": #{total.round}GB Total; #{used.round}GB (#{up}%) Used |
  \'Pool Size #{pool}\'=#{used.round}GB;#{(warn.to_f / 100) * total.round};#{(crit.to_f / 100) * total.round};0;#{total.round}"
end

def set_group(filter = '', pools = {})
  pools.each do |key, val|
    next unless key =~ %r{#{ filter }}
    fp = (val[:freepool].nil? || val[:freepool].empty?) ? 0.00 : pools[val[:freepool]][:size]

    pools[filter] = if pools[filter].nil?
                      {
                        size: val[:size] + fp,
                        used: val[:used],
                      }
                    else
                      {
                        size: val[:size] + pools[filter][:size] + fp,
                        used: val[:used] + pools[filter][:used],
                      }
                    end
  end
end

def set_ex(filter = '', pools = {}, warn = 75, crit = 90)
  ex = 3
  return ex if filter.empty? || pools.empty?

  pools.each do |key, val|
    next unless key == filter
    res = 100 * val[:used] / val[:size]
    ex = if res < warn then 0
         elsif res >= warn && res < crit then 1
         elsif res >= crit then 2
         else 3
         end
  end
  ex
end

def s_media_ex(media = {})
  ex = 3
  return ex if media.empty?
  ex = if media[:status] == 'Good' then 0
       elsif media[:status] == 'Fair' then 1
       elsif media[:status] == 'Poor' then 2
       elsif media[:protection] == 'Permanent' then 2
       else 3
       end
  ex
end
###############

p = `/opt/omni/bin/omnimm -show_pool | /bin/awk '$0 ~ /#{ options[:pool] }/ {print $2}'`.split
p.each do |o|
  list[o] = get_info(o)
  fp = list[o][:freepool]

  list[fp] = get_info(fp) unless fp.empty?
end

options[:filter].each { |filter| set_group(filter, list) }
options[:filter].each do |filter|
  e = set_ex(filter, list).to_i
  ex = e if ex == 3
  ex = e if (e == 1 || e == 2) && e > ex
end

list.each do |key, val|
  next if key =~ %r{freepool}
  total = (val[:freepool].nil? || val[:freepool].empty?) ? val[:size] : val[:size] + list[(val[:freepool]).to_s][:size]
  used  = val[:used]

  usage << get_usage(key, total, used, options[:warning], options[:critical])
  next if options[:filter].include?(key)
  list[key][:media] = get_media_info(key)
  list[key][:media].each do |key2, val2|
    e = s_media_ex(val2)
    media_stat << "Fair media found: #{key2}" if e == 1
    media_stat << "Poor media or media with permanent protection found: #{key2}" if e == 2
    ex = e if ex == 3
    ex = e if (e == 1 || e == 2) && e > ex
  end
end

puts usage.join("\n")
puts media_stat.join("\n") unless media_stat.empty?

exit ex
