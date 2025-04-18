class KoperasiModel {
  String? id;
  String? nama;

  KoperasiModel({this.id, this.nama});

  KoperasiModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    if (nama != null) data['nama'] = nama;
    return data;
  }
}
