class Acct{
  late final int id;
  late final String acct;
  late final double tgain;
  late final double tspend;

  static final columns = ["id","acct", "tgain", "tspend"];
  Acct(this.id,this.acct,this.tgain,this.tspend);
  factory Acct.fromMap(Map<String, dynamic> data) {
    return Acct(
      data['id'],
      data['acct'],
      data['tgain'],
      data['tspend'],
    );
  }
  Map<String, dynamic> toMap() => {
    "id": id,
    "acct": acct,
    "tgain": tgain,
    "tspend": tspend,
  };
}