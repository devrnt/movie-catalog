class Torrent {
  String url;
  String hash;
  String quality;
  num size; // bytes
  DateTime dateUploaded;
  int seeds;
  int peers;

  Torrent(this.url, this.hash, this.quality, this.size, this.dateUploaded,
      this.seeds, this.peers);

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
        json['url'] as String,
        json['hash'] as String,
        json['quality'] as String,
        json['size_bytes'] as num,
        json['dateUploaded'] as DateTime,
        json['seeds'] as int,
        json['peers'] as int);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'hash': hash,
        'quality': quality,
        'size': size,
        'dateUploaded': dateUploaded,
        'seeds': seeds,
        'peers': peers,
      };
}
