class AttachmentDto {
  final String? attachmentUuid;
  final String? fileLink;
  final String? fileName;
  final int? fileSize;
  final String? attachmentType;
  final DateTime? createdDate;

  AttachmentDto({
    this.attachmentUuid,
    this.fileLink,
    this.fileName,
    this.fileSize,
    this.attachmentType,
    this.createdDate,
  });

  factory AttachmentDto.fromJson(Map<String, dynamic> json) {
    return AttachmentDto(
      attachmentUuid: json['attachmentUuid'] as String?,
      fileLink: json['fileLink'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      attachmentType: json['attachmentType'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachmentUuid': attachmentUuid,
      'fileLink': fileLink,
      'fileName': fileName,
      'fileSize': fileSize,
      'attachmentType': attachmentType,
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024)
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage {
    if (fileName == null) return false;
    final extension = fileName!.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  String get displayName {
    return fileName ?? 'Unnamed file';
  }
}
