# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 도로명 주소 업데이트
# 111102100001|삼일대로|Samil-daero|06|서울특별시|Seoul|종로구|Jongno-gu|종로2가|Jongno 2(i)-ga|1|138|0||||
IO.foreach('street_address') do |line| 
    str_arr = line.split('|')

    # 도로명 주소 INSERT
    Address.create(city: str_arr[4], ku: str_arr[6], dong: str_arr[8], street: str_arr[1])
end
puts("[LOG] 도로명 주소 업데이트 완료")

# 지번 주소 업데이트
# 1121510300102320014024416|1|1121510300|서울특별시|광진구|구의동||0|232|14|1
# IO.foreach('lot_address') do |line| 
#     str_arr = line.split('|')

#     # 도로명 주소 INSERT
#     Lotaddress.create(city: str_arr[3], ku: str_arr[4], dong: str_arr[5], lot: (str_arr[8] + '-' + str_arr[9]))
# end
# puts("[LOG] 지번 주소 업데이트 완료")
