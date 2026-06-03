import { useEffect, useState } from 'react';
import { useColorScheme as useRNColorScheme, type ColorSchemeName } from 'react-native';

/**
 * To support static rendering, this value needs to be re-calculated on the client side for web
 */
export function useColorScheme(): ColorSchemeName {
  const [hasHydrated, setHasHydrated] = useState(false);

  useEffect(() => {
    setHasHydrated(true);
  }, []);

  const colorScheme = useRNColorScheme();

  if (!hasHydrated) {
    return undefined as unknown as ColorSchemeName;
  }

  return colorScheme ?? undefined as unknown as ColorSchemeName;
}
