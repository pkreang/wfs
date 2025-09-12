class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String accessToken;
  final String? tokenType;
  final String? userRoleName;
  final String? userName;
  final String? error;
  final String? userID;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.accessToken = "",
    this.tokenType,
    this.userRoleName,
    this.userName,
    this.error,
    this.userID,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? accessToken,
    String? tokenType,
    String? userRoleName,
    String? userName,
    String? error,
    String? userID,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      userRoleName: userRoleName ?? this.userRoleName,
      userName: userName ?? this.userName,
      userID: userID ?? this.userID,
      error: error, 
    );
  }
}