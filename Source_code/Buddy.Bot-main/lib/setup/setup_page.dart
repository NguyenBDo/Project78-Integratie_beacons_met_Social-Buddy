import 'package:auth_repository/auth_repository.dart';
import 'package:buddy_bot/setup/setup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';

typedef ContextAwareCallback = void Function(BuildContext);

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SetupCubit(
        authRepository: context.read<AuthRepository>(),
      )
        ..subscribeToCurrentUser()
        ..checkPermissions(),
      child: const SetupView(),
    );
  }
}

class SetupView extends StatelessWidget {
  const SetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _UserSignInStatus(),
            Gap(8),
            FractionallySizedBox(
              widthFactor: 0.4,
              child: Divider(),
            ),
            Gap(8),
            _CameraPermissionStatus(),
          ],
        ),
      ),
    );
  }
}

class _CameraPermissionStatus extends StatelessWidget {
  const _CameraPermissionStatus();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SetupCubit>();
    final state = cubit.state;

    switch (state.cameraPermissionStatus) {
      case PermissionStatus.restricted:
      case PermissionStatus.denied:
        return _PermissionPrompt(
          onTapGrant: cubit.attemptGrantPermissions,
        );
      case PermissionStatus.permanentlyDenied:
        return _OpenSettingsPrompt(
          onTapOpen: openAppSettings,
          onTapCheck: cubit.attemptGrantPermissions,
        );
      case PermissionStatus.granted:
        return const _CameraPermissionGrantedText();
      case null:
      // ignore: no_default_cases
      default:
        return const _CheckingPermissionsText();
    }
  }
}

class _CheckingPermissionsText extends StatelessWidget {
  const _CheckingPermissionsText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('Checking permissions...'),
        Gap(8),
        CupertinoActivityIndicator(),
      ],
    );
  }
}

class _PermissionPrompt extends StatelessWidget {
  const _PermissionPrompt({
    required this.onTapGrant,
  });

  final VoidCallback onTapGrant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Camera permission is required to run this app.'),
        const Gap(16),
        ElevatedButton(
          onPressed: onTapGrant,
          child: const Text('Grant permission'),
        ),
      ],
    );
  }
}

class _OpenSettingsPrompt extends StatelessWidget {
  const _OpenSettingsPrompt({
    required this.onTapOpen,
    required this.onTapCheck,
  });

  final VoidCallback onTapOpen;
  final VoidCallback onTapCheck;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Camera permission is required to run this app.'),
        const Gap(16),
        ElevatedButton(
          onPressed: onTapOpen,
          child: const Text('Open Settings'),
        ),
        const Gap(16),
        ElevatedButton(
          onPressed: onTapCheck,
          child: const Text('Check Again'),
        ),
      ],
    );
  }
}

class _CameraPermissionGrantedText extends StatelessWidget {
  const _CameraPermissionGrantedText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('Camera permission granted!'),
        Gap(8),
        Icon(
          CupertinoIcons.check_mark,
          color: CupertinoColors.activeGreen,
        ),
      ],
    );
  }
}

class _UserSignInStatus extends StatelessWidget {
  const _UserSignInStatus();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SetupCubit>();
    final state = cubit.state;

    if (state.currentUser != null) {
      return _SignedInText(user: state.currentUser!);
    } else {
      return _SignInPrompt(
        onTapSignIn: cubit.signInWithGoogle,
      );
    }
  }
}

class _SignedInText extends StatelessWidget {
  const _SignedInText({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Signed in as ${user.emailAddress ?? user.id}'),
        const Gap(8),
        const Icon(
          CupertinoIcons.check_mark,
          color: CupertinoColors.activeGreen,
        ),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({
    required this.onTapSignIn,
  });

  final VoidCallback onTapSignIn;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTapSignIn,
      child: const Text('Sign in with Google'),
    );
  }
}
