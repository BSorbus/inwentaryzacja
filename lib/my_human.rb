class MyHuman

  def filesize(size)
    units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB']

    return '0.0 B' if size == 0
    exp = (Math.log(size) / Math.log(1000)).to_i
    exp += 1 if (size.to_f / 1000 ** exp >= 1000 - 0.05)
    exp = 6 if exp > 6 

    '%.1f %s' % [size.to_f / 1000 ** exp, units[exp]]
  end

end