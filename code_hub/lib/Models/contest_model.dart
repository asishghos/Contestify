class ContestModel {
  Meta? meta;
  List<Objects>? objects;

  ContestModel({this.meta, this.objects});

  ContestModel.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['objects'] != null) {
      objects =
          json['objects'].map<Objects>((v) => Objects.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (objects != null) {
      data['objects'] = objects!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Meta {
  int? limit;
  String? next;
  int? offset;
  String? previous;
  int? totalCount;

  Meta({this.limit, this.next, this.offset, this.previous, this.totalCount});

  Meta.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    next = json['next'];
    offset = json['offset'];
    previous = json['previous'];
    totalCount = json['total_count'];
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'next': next,
      'offset': offset,
      'previous': previous,
      'total_count': totalCount,
    };
  }
}

class Objects {
  int? duration;
  String? end;
  String? event;
  String? href;
  int? id;
  Resource? resource;
  String? start;

  Objects(
      {this.duration,
      this.end,
      this.event,
      this.href,
      this.id,
      this.resource,
      this.start});

  Objects.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    end = json['end'];
    event = json['event'];
    href = json['href'];
    id = json['id'];
    resource =
        json['resource'] != null ? Resource.fromJson(json['resource']) : null;
    start = json['start'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['duration'] = duration;
    data['end'] = end;
    data['event'] = event;
    data['href'] = href;
    data['id'] = id;
    if (resource != null) {
      data['resource'] = resource!.toJson();
    }
    data['start'] = start;
    return data;
  }
}

class Resource {
  String? icon;
  int? id;
  String? name;

  Resource({this.icon, this.id, this.name});

  Resource.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'id': id,
      'name': name,
    };
  }
}
