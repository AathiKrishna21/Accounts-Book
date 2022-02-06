class Acct{
  late final int id;
  late final String acct;

  static final columns = ["id","acct"];
  Acct(this.id,this.acct);
  factory Acct.fromMap(Map<String, dynamic> data) {
    return Acct(
      data['id'],
      data['acct'],
    );
  }
  Map<String, dynamic> toMap() => {
    "id": id,
    "acct": acct,
  };
}