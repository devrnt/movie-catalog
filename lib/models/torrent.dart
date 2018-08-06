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
}
