import 'package:go_router/go_router.dart';
import 'package:recipe_app/core/routing/routes.dart';
import 'package:recipe_app/data/data_source/procedure_data_source_impl.dart';
import 'package:recipe_app/data/data_source/recipe_data_source_impl.dart';
import 'package:recipe_app/data/repository/bookmark_repository_impl.dart';
import 'package:recipe_app/data/repository/procedure_repository_impl.dart';
import 'package:recipe_app/data/repository/recipe_repository_impl.dart';
import 'package:recipe_app/domain/use_case/get_saved_recipes_use_case.dart';
import 'package:recipe_app/presentation/home/home_screen.dart';
import 'package:recipe_app/presentation/ingredient/ingredient_view_model.dart';
import 'package:recipe_app/presentation/ingredient/screen/ingreident_root.dart';
import 'package:recipe_app/presentation/main/main_screen.dart';
import 'package:recipe_app/presentation/saved_recipes/saved_recipes_view_model.dart';
import 'package:recipe_app/presentation/saved_recipes/screen/saved_recipes_root.dart';
import 'package:recipe_app/presentation/search_recipes/screen/search_recipes_root.dart';
import 'package:recipe_app/presentation/search_recipes/search_recipes_view_model.dart';
import 'package:recipe_app/presentation/sign_in/sign_in_screen.dart';
import 'package:recipe_app/presentation/sign_up/sign_up_screen.dart';
import 'package:recipe_app/presentation/splash/splash_screen.dart';

final router = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) {
        return SplashScreen(
          onStartCooking: () {
            context.go(Routes.signIn);
          },
        );
      },
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) {
        return SignInScreen(
          onSignInClick: () {
            context.go(Routes.home);
          },
          onSignUpClick: () {
            context.go(Routes.signUp);
          },
        );
      },
    ),
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) {
        return SignUpScreen(
          onSignInClick: () {
            context.go(Routes.signIn);
          },
          onSignUpClick: () {
            context.go(Routes.signIn);
          },
        );
      },
    ),
    GoRoute(
      path: Routes.searchRecipes,
      builder: (context, state) {
        final viewModel = SearchRecipesViewModel(
          RecipeRepositoryImpl(RecipeDataSourceImpl()),
        );

        viewModel.findRecipes();

        return SearchRecipeRoot(viewModel: viewModel);
      },
    ),

    GoRoute(
      path: '${Routes.ingredientRecipes}/:id',
      builder: (context, state) {
        final int id = int.parse(state.pathParameters['id']!);
        final IngredientViewModel viewModel = IngredientViewModel(
          RecipeRepositoryImpl(RecipeDataSourceImpl()),
          ProcedureRepositoryImpl(ProcedureDataSourceImpl()),
        );

        viewModel.findRecipeById(id);

        return IngredientRoot(viewModel: viewModel);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(
          body: navigationShell,
          currentPageIndex: navigationShell.currentIndex,
          onChangeIndex: (value) {
            navigationShell.goBranch(
              value,
              initialLocation: value == navigationShell.currentIndex,
            );
          },
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) {
                return HomeScreen(
                  onSearchTap: () {
                    context.push(Routes.searchRecipes);
                  },
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.savedRecipes,
              builder: (context, state) {
                final viewModel = SavedRecipesViewModel(
                  GetSavedRecipesUseCase(
                    BookmarkRepositoryImpl(),
                    RecipeRepositoryImpl(RecipeDataSourceImpl()),
                  ),
                );

                viewModel.findRecipes();

                return SavedRecipeRoot(
                  viewModel: viewModel,
                  onCardClick: (int id) {
                    context.push('${Routes.ingredientRecipes}/$id');
                  },
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
