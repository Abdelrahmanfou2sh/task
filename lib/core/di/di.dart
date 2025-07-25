import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/data/repositories/kyc_repository.dart';
import '../../features/auth/presentation/cubit/kyc_cubit.dart';
import '../../features/customer/data/repositories/send_money_repository.dart';
import '../../features/customer/presentation/cubit/send_money_cubit.dart';
import '../../features/customer/data/repositories/transaction_history_repository.dart';
import '../../features/customer/presentation/cubit/transaction_history_cubit.dart';
import '../../features/customer/data/repositories/deposit_withdraw_repository.dart';
import '../../features/customer/presentation/cubit/deposit_withdraw_cubit.dart';
import '../../features/customer/data/repositories/customer_home_repository.dart';
import '../../features/customer/presentation/cubit/customer_home_cubit.dart';
import '../../features/agent/data/repositories/agent_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  // Register KycRepository
  sl.registerLazySingleton<KycRepository>(
    () => KycRepository(storage: sl<FirebaseStorage>(), firestore: sl()),
  );
  sl.registerLazySingleton<SendMoneyRepository>(
    () => SendMoneyRepository(firestore: sl()),
  );
  sl.registerLazySingleton<TransactionHistoryRepository>(
    () => TransactionHistoryRepository(firestore: sl()),
  );
  sl.registerLazySingleton<DepositWithdrawRepository>(
    () => DepositWithdrawRepository(firestore: sl()),
  );
  sl.registerLazySingleton<CustomerHomeRepository>(
    () => CustomerHomeRepository(firestore: sl()),
  );
  sl.registerLazySingleton<AgentRepository>(
    () => AgentRepository(firestore: sl<FirebaseFirestore>()),
  );

  // Cubits
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => KycCubit(sl()));
  sl.registerFactory(() => SendMoneyCubit(sl()));
  sl.registerFactory(() => TransactionHistoryCubit(sl()));
  sl.registerFactory(() => DepositWithdrawCubit(sl()));
  sl.registerFactory(() => CustomerHomeCubit(sl()));
} 