import { useColorScheme as useRNColorScheme, type ColorScheme } from 'react-native';

export function useColorScheme(): ColorScheme | null {
  return useRNColorScheme();
}
