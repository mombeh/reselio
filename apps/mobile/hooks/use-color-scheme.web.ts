import { useEffect, useState } from 'react';
import { useColorScheme as useRNColorScheme, type ColorScheme } from 'react-native';

/**
 * To support static rendering, this value needs to be re-calculated on the client side for web
 */
export function useColorScheme(): ColorScheme | null {
  const [hasHydrated, setHasHydrated] = useState(false);

  useEffect(() => {
    setHasHydrated(true);
  }, []);

  const colorScheme = useRNColorScheme();

  if (!hasHydrated || !colorScheme) {
    return 'light';
  }

  return colorScheme;
}
