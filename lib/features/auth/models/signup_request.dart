class SignupRequest {
  final String username;
  final String email;
  final String password;
  final String? phone;
  final String? firstName;
  final String? lastName;

  const SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'password': password,
    };
    if (phone != null && phone!.trim().isNotEmpty) {
      data['phone'] = phone!.trim();
    }
    if (firstName != null && firstName!.trim().isNotEmpty) {
      data['first_name'] = firstName!.trim();
    }
    if (lastName != null && lastName!.trim().isNotEmpty) {
      data['last_name'] = lastName!.trim();
    }
    return data;
  }
}
