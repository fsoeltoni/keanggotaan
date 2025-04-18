class PekerjaanModel {
  String? id;
  String? nama;

  PekerjaanModel({this.id, this.nama});

  PekerjaanModel.fromJson(Map<String, dynamic> json) {
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
