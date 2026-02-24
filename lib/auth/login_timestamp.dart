/// Tracks last successful login time.
/// Used to avoid false logout on 401 during the first few seconds after login
/// (handles race with initial API calls that may fail before token is fully propagated).
DateTime? lastLoginTime;
