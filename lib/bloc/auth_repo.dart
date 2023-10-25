class AuthRepository{
    Future<void> login() async {
        print('attempting login');
        await Future.delayed(Duration(seconds: 3));
        print('logged in');
        throw Exception('failed log in');
    }

    Future<void> signUp({
        required String username,
        required String email,
        required String password,
    }) async {
        await Future.delayed(Duration(seconds: 2));
    }



}



