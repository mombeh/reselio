import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: jest.Mocked<AuthService>;
  let usersService: jest.Mocked<UsersService>;

  const mockAuthService = {
    createPasswordResetToken: jest.fn(),
    verifyPasswordResetToken: jest.fn(),
    login: jest.fn(),
    validateUser: jest.fn(),
    googleLogin: jest.fn(),
    googleMobileLogin: jest.fn(),
  };

  const mockUsersService = {
    create: jest.fn(),
    findByEmail: jest.fn(),
    updatePasswordByUserId: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        { provide: AuthService, useValue: mockAuthService },
        { provide: UsersService, useValue: mockUsersService },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get(AuthService);
    usersService = module.get(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('forgotPassword', () => {
    it('should return a reset token when the email exists', async () => {
      mockAuthService.createPasswordResetToken.mockResolvedValue('reset-token-123');

      const result = await controller.forgotPassword({ email: 'jane@example.com' });

      expect(result.message).toContain('password reset instructions');
      expect(result.resetToken).toBe('reset-token-123');
      expect(authService.createPasswordResetToken).toHaveBeenCalledWith('jane@example.com');
    });

    it('should not reveal whether the email exists when not found', async () => {
      mockAuthService.createPasswordResetToken.mockResolvedValue(null);

      const result = await controller.forgotPassword({ email: 'unknown@example.com' });

      expect(result.message).toContain('password reset instructions');
      expect(result.resetToken).toBeNull();
    });
  });

  describe('resetPassword', () => {
    it('should reset password successfully when tokens match and passwords are equal', async () => {
      mockAuthService.verifyPasswordResetToken.mockResolvedValue({
        userId: 'user1',
        email: 'jane@example.com',
      });
      mockUsersService.updatePasswordByUserId.mockResolvedValue({});

      const result = await controller.resetPassword({
        token: 'valid-token',
        newPassword: 'NewPass123!',
        confirmPassword: 'NewPass123!',
      });

      expect(result.message).toBe('Password has been reset successfully');
      expect(authService.verifyPasswordResetToken).toHaveBeenCalledWith('valid-token');
      expect(usersService.updatePasswordByUserId).toHaveBeenCalledWith('user1', 'NewPass123!');
    });

    it('should throw BadRequestException if passwords do not match', async () => {
      await expect(
        controller.resetPassword({
          token: 'valid-token',
          newPassword: 'NewPass123!',
          confirmPassword: 'OtherPass123!',
        }),
      ).rejects.toThrow();
    });
  });
});
