class Trxn{
  late final int id;
  late final String date;
  late final String reason;
  late final int is_gain;
  late final double total;
  late final int title;

  static final columns = ["id","date", "reason", "is_gain", "total", "title"];
  Trxn(this.id,this.date,this.reason,this.is_gain,this.total,this.title);
  factory Trxn.fromMap(Map<String, dynamic> data) {
    return Trxn(
      data['id'],
      data['date'],
      data['reason'],
      data['is_gain'],
      data['total'],
      data['title'],
    );
  }
  Map<String, dynamic> toMap() => {
    "id": id,
    "date": date,
    "reason": reason,
    "is_gain": is_gain,
    "total": total,
    "title": title,
  };
}