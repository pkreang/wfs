class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String accessToken;
  final String? tokenType;
  final String? userRoleID;
  final String? userRoleName;
  final String? userName;
  final String? error;
  final String? userID;
  final String? email;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.accessToken = "",
    this.tokenType,
    this.userRoleID,
    this.userRoleName,
    this.userName,
    this.error,
    this.userID,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? accessToken,
    String? tokenType,
    String? userRoleID,
    String? userRoleName,
    String? userName,
    String? error,
    String? userID,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      userRoleID: userRoleID ?? this.userRoleID,
      userRoleName: userRoleName ?? this.userRoleName,
      userName: userName ?? this.userName,
      userID: userID ?? this.userID,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
    );
  }

  bool get isSuperAdmin => userRoleID == "D9ACA4E5-7CC6-466E-B192-776037AD1A80" || userRoleID == "91FA9057-F815-456C-8D7E-C8CCCBC2A805";
  bool get isSupervisor => userRoleID == "8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6";
}
