import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';
import '../theme/theme_cubit.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/checklist_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/checklist_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_assigned_checklist_usecase.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/dashboard/bloc/checklist_bloc.dart';
import '../../data/datasources/checklist_detail_remote_datasource.dart';
import '../../data/repositories/checklist_detail_repository_impl.dart';
import '../../domain/repositories/checklist_detail_repository.dart';
import '../../domain/usecases/get_checklist_details_usecase.dart';
import '../../presentation/checklist/bloc/checklist_detail_bloc.dart';
import '../../data/datasources/upload_file_datasource.dart';
import '../../data/repositories/upload_file_repository_impl.dart';
import '../../domain/repositories/upload_file_repository.dart';
import '../../domain/usecases/upload_checklist_file_usecase.dart';
import '../../data/datasources/submit_checklist_datasource.dart';
import '../../data/repositories/submit_checklist_repository_impl.dart';
import '../../domain/repositories/submit_checklist_repository.dart';
import '../../domain/usecases/submit_checklist_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<FlutterSecureStorage>()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  // Checklist Data Sources
  sl.registerLazySingleton<ChecklistRemoteDataSource>(
    () => ChecklistRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  // Checklist Repositories
  sl.registerLazySingleton<ChecklistRepository>(
    () => ChecklistRepositoryImpl(
        remoteDataSource: sl<ChecklistRemoteDataSource>()),
  );

  // Checklist Use Cases
  sl.registerLazySingleton<GetAssignedChecklistUseCase>(
    () => GetAssignedChecklistUseCase(sl<ChecklistRepository>()),
  );

  // Checklist BLoC
  sl.registerFactory<ChecklistBloc>(
    () => ChecklistBloc(useCase: sl<GetAssignedChecklistUseCase>()),
  );

  // Checklist Detail
  sl.registerLazySingleton<ChecklistDetailRemoteDataSource>(
    () => ChecklistDetailRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ChecklistDetailRepository>(
    () => ChecklistDetailRepositoryImpl(
        remoteDataSource: sl<ChecklistDetailRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetChecklistDetailsUseCase>(
    () => GetChecklistDetailsUseCase(sl<ChecklistDetailRepository>()),
  );

  // File Upload
  sl.registerLazySingleton<UploadFileDataSource>(
    () => UploadFileDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<UploadFileRepository>(
    () => UploadFileRepositoryImpl(dataSource: sl<UploadFileDataSource>()),
  );
  sl.registerLazySingleton<UploadChecklistFileUseCase>(
    () => UploadChecklistFileUseCase(sl<UploadFileRepository>()),
  );

  // Submit checklist
  sl.registerLazySingleton<SubmitChecklistDataSource>(
    () => SubmitChecklistDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<SubmitChecklistRepository>(
    () => SubmitChecklistRepositoryImpl(dataSource: sl<SubmitChecklistDataSource>()),
  );
  sl.registerLazySingleton<SubmitChecklistUseCase>(
    () => SubmitChecklistUseCase(sl<SubmitChecklistRepository>()),
  );

  sl.registerFactory<ChecklistDetailBloc>(
    () => ChecklistDetailBloc(
      useCase: sl<GetChecklistDetailsUseCase>(),
      uploadUseCase: sl<UploadChecklistFileUseCase>(),
      submitUseCase: sl<SubmitChecklistUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Theme
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<FlutterSecureStorage>()),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
}
