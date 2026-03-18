'use client';

import { useState, useEffect } from 'react';

interface Country {
  code: string;
  name: string;
  dialCode: string;
  flag: string;
  pattern: RegExp;
}

const COUNTRIES: Country[] = [
  { code: 'CM', name: 'Cameroon', dialCode: '+237', flag: '🇨🇲', pattern: /^6[0-9]{8}$/ },
  { code: 'NG', name: 'Nigeria', dialCode: '+234', flag: '🇳🇬', pattern: /^7[0-9]{8}$/ },
  { code: 'GH', name: 'Ghana', dialCode: '+233', flag: '🇬🇭', pattern: /^2[0-9]{8}$/ },
  { code: 'SN', name: 'Senegal', dialCode: '+221', flag: '🇸🇳', pattern: /^7[0-9]{8}$/ },
  { code: 'CI', name: 'Ivory Coast', dialCode: '+225', flag: '🇨🇮', pattern: /^0[0-9]{8}$/ },
  { code: 'KE', name: 'Kenya', dialCode: '+254', flag: '🇰🇪', pattern: /^7[0-9]{8}$/ },
  { code: 'TZ', name: 'Tanzania', dialCode: '+255', flag: '🇹🇿', pattern: /^6[0-9]{8}$/ },
  { code: 'ZA', name: 'South Africa', dialCode: '+27', flag: '🇿🇦', pattern: /^6[0-9]{8}$/ },
  { code: 'EG', name: 'Egypt', dialCode: '+20', flag: '🇪🇬', pattern: /^1[0-9]{9}$/ },
  { code: 'MA', name: 'Morocco', dialCode: '+212', flag: '🇲🇦', pattern: /^6[0-9]{8}$/ },
  { code: 'GB', name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧', pattern: /^7[0-9]{9}$/ },
  { code: 'US', name: 'United States', dialCode: '+1', flag: '🇺🇸', pattern: /^[2-9][0-9]{9}$/ },
  { code: 'FR', name: 'France', dialCode: '+33', flag: '🇫🇷', pattern: /^6[0-9]{8}$/ },
  { code: 'DE', name: 'Germany', dialCode: '+49', flag: '🇩🇪', pattern: /^1[5-6][0-9]{9}$/ },
  { code: 'CN', name: 'China', dialCode: '+86', flag: '🇨🇳', pattern: /^1[3-9][0-9]{9}$/ },
  { code: 'IN', name: 'India', dialCode: '+91', flag: '🇮🇳', pattern: /^[6-9][0-9]{9}$/ },
];

interface PhoneInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  label?: string;
  error?: string;
  required?: boolean;
}

export default function PhoneInput({
  value,
  onChange,
  placeholder = 'Enter phone number',
  label = 'Phone Number',
  error,
  required = false,
}: PhoneInputProps) {
  const [selectedCountry, setSelectedCountry] = useState<Country>(COUNTRIES[0]!); // Default to Cameroon
  const [phoneNumber, setPhoneNumber] = useState('');
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [validationError, setValidationError] = useState('');

  // Parse initial value if provided
  useEffect(() => {
    if (value) {
      // Try to match with known country codes
      const matchedCountry = COUNTRIES.find((country) => value.startsWith(country.dialCode));
      if (matchedCountry) {
        setSelectedCountry(matchedCountry);
        setPhoneNumber(value.replace(matchedCountry.dialCode, ''));
      } else {
        setPhoneNumber(value);
      }
    }
  }, [value]);

  const handleCountrySelect = (country: Country) => {
    setSelectedCountry(country);
    setDropdownOpen(false);
    validateAndUpdate(phoneNumber, country);
  };

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const input = e.target.value.replace(/[^\d]/g, ''); // Only allow digits
    setPhoneNumber(input);
    validateAndUpdate(input, selectedCountry);
  };

  const validateAndUpdate = (phone: string, country: Country) => {
    if (!phone) {
      setValidationError('');
      onChange('');
      return;
    }

    if (!country.pattern.test(phone)) {
      setValidationError(`Invalid phone number for ${country.name}`);
      onChange(country.dialCode + phone);
    } else {
      setValidationError('');
      onChange(country.dialCode + phone);
    }
  };

  const displayError = error || validationError;

  return (
    <div>
      {label && (
        <label className="block text-sm font-medium text-gray-700 mb-1">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}
      <div className="flex">
        {/* Country Selector */}
        <div className="relative">
          <button
            type="button"
            onClick={() => setDropdownOpen(!dropdownOpen)}
            className="flex items-center gap-2 px-3 py-2 border border-gray-300 border-r-0 rounded-l-lg bg-gray-50 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-rose-500"
          >
            <span className="text-lg">{selectedCountry.flag}</span>
            <span className="text-sm text-gray-700">{selectedCountry.dialCode}</span>
            <svg
              className={`w-4 h-4 text-gray-500 transition-transform ${dropdownOpen ? 'rotate-180' : ''}`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          {dropdownOpen && (
            <div className="absolute z-50 mt-1 w-64 max-h-60 overflow-y-auto bg-white border border-gray-300 rounded-lg shadow-lg">
              {COUNTRIES.map((country) => (
                <button
                  key={country.code}
                  type="button"
                  onClick={() => handleCountrySelect(country)}
                  className={`flex items-center gap-3 w-full px-3 py-2 text-left hover:bg-gray-100 ${
                    selectedCountry.code === country.code ? 'bg-rose-50' : ''
                  }`}
                >
                  <span className="text-lg">{country.flag}</span>
                  <span className="text-sm text-gray-700 flex-1">{country.name}</span>
                  <span className="text-sm text-gray-500">{country.dialCode}</span>
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Phone Number Input */}
        <input
          type="tel"
          value={phoneNumber}
          onChange={handlePhoneChange}
          placeholder={placeholder}
          className={`flex-1 px-3 py-2 border rounded-r-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent text-gray-900 bg-white ${
            displayError ? 'border-red-500' : 'border-gray-300'
          }`}
        />
      </div>
      {displayError && (
        <p className="mt-1 text-sm text-red-500">{displayError}</p>
      )}
      <p className="mt-1 text-xs text-gray-500">
        Example: {selectedCountry.dialCode} {selectedCountry.pattern.source.replace(/[\^$]/g, '').replace(/\[0-9\]/g, 'X').replace(/X/g, '0-9').substring(0, 15)}
      </p>
    </div>
  );
}
